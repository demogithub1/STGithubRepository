public class Branch_ControllerExtension 
{    
    
    private string caseid;

    private final Case caseRecord;
    private ApexPages.StandardController stdcontroller;
    
    public Branch_ControllerExtension(ApexPages.StandardController controller)    
    {        
        stdcontroller = controller;
        caseRecord = (Case)controller.getRecord();
        
        //Start changes for CMI 2014
        caseRecord.Special_Initiatives__c='CMI';
        //End changes for CMI 2014
        
        caseRecord.RecordTypeId = [select id from RecordType where name='Client Case'].id;
        caseRecord.Status = 'Send to Research';
        caseRecord.Business_or_Personal__c = 'Personal';
        caseRecord.Is_This_a_Client__c = 'Yes';
        caseRecord.Origin = 'Branch Form';
        CCErrorDisplay = '';
    }
    
    //public Case ClientCaseRecord {get{return caseRecord;} set{caseRecord=value;}}
    public Case ClientCaseRecord {get{return caseRecord;}}
    public string CCErrorDisplay {get; set;}
    public boolean errorTMorDept {get; set;}

    /*********************************************************************************/     
    /*                         S A V E   O V E R R I D E                             */     
    /*********************************************************************************/    
    public PageReference save()     
    {
        PageReference pr;
        boolean validsave = true;        
        CCErrorDisplay = '';
        errorTMorDept = false;
                                
        if (caseRecord.Type!='Complaint' && caseRecord.Type!='Positive Feedback/Compliment')        
        {            
            //CCErrorDisplay = 'Please select a Case Type.';
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please select a Case Type.');        
            ApexPages.addMessage(message);                        
            validsave = false;        
        }

        if (caseRecord.Is_Feedback_regarding_a_TM_Dept__c ==null || caseRecord.Is_Feedback_regarding_a_TM_Dept__c =='none')        
        {            
            //CCErrorDisplay = 'Please select a Case Type.';
            //ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please select a value.');        
            //ApexPages.addMessage(message);
            errorTMorDept = true ;                         
            validsave = false;        
        }  

        //start changes for CMI pilot
        //Check if Submitter(Name/RACFID) is provided
        String testSubmitter = caseRecord.Submitter__c; 
        if(testSubmitter=='')
        {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Your Name/RACFID is required.');        
            ApexPages.addMessage(message);            
            validsave = false;
        }
        //end changes for CMI pilot
        // The following do not work on lookup fields which expect a valid id
        // ... if (caseRecord.Submitter__c == null) ... if (caseRecord.Submitter__c == '')
        // instead a try/catch must be used to intercept the string exception error when it is thrown.

        try
        {
            Id testSubmitterId = caseRecord.Submitter__c;
        }   
        catch(System.StringException e)                    
        {            
            //if (caseRecord.Submitter__c == ' ')
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Your Name/RACFID is required.');        
            ApexPages.addMessage(message);            
            validsave = false;        
        }
        
        //Start changes for CMI 2014
        //If Is_This_a_Client__c == 'Yes' then selection of a client is required.
        if(caseRecord.Is_This_a_Client__c == 'Yes' && caseRecord.CIN__c==null)
        {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'For a Case creation, selection of a Client using "Search Client" button is Required.');        
            ApexPages.addMessage(message);                        
            validsave = false;        
        }
        //End changes for CMI 2014
                       
        if (caseRecord.Is_Feedback_regarding_a_TM_Dept__c == 'STOLI Teammate')
        {
             //start changes for CMI pilot
             //check if teammate search is provided
             String testTeammateSearch = caseRecord.Teammate_Search__c; 
             if(testTeammateSearch =='')
             {            
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'A selection for Teammate Search is required.');        
                ApexPages.addMessage(message);            
                validsave = false;        
             }
             //end changes for CMI pilot
             try
             {
                Id testTeammateSearchId = caseRecord.Teammate_Search__c;
             }   
             catch(System.StringException e)                    
             {            
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'A selection for Teammate Search is required.');        
                ApexPages.addMessage(message);            
                validsave = false;        
             }                
        }

        if (validsave)        
        {
            // Pad the CIN with leading zeros to 11 digits.            
            if (caseRecord.CIN__c != null)
            {
                integer cinLength = caseRecord.CIN__c.Trim().Length();
                if (cinLength > 0 && cinLength < 11)
                {
                    integer paddingLength = 11 - cinLength;
                    string tempStr = '';
                    for (integer i=0; i<paddingLength; i++) tempStr += '0';
                    caseRecord.CIN__c = tempStr + caseRecord.CIN__c.Trim();
                }
            }
        
            // If a compliment is to be saved, blank all unnecessary fields that may have been 
            // inadvertently set by originally filling out a complaint.
            if(caserecord.Type == 'Positive Feedback/Compliment')
            {
                // *** Call information ***     -- Record all 
                // *** Client information ***
                //caseRecord.Is_this_a_Client__c = null;
                //caseRecord.Business_or_Personal__c = null;
                caseRecord.Client_Type__c = null;
                caseRecord.Account_Number__c = '';
                caseRecord.Account_Type__c = null;
            
                // *** Feedback information *** - Record all 

                // *** Feedback Category ***
                caseRecord.Initiative_Tracking__c = null;
            
                // *** Resolution Details ***
                caseRecord.Refund__c = null;
                caseRecord.Client_Flight_Risk__c = false;
                caseRecord.Did_You_Save_this_Client_s_Relationship__c = null;
                caseRecord.Save_action_taken__c = null;
                caseRecord.Number_of_Accounts_Saved__c = null;
                caseRecord.Available_balance_on_the_account__c = 0;
                caseRecord.Client_Follow_Up_Needed__c = null;
                caseRecord.Client_Contact_Number__c = '';
                caseRecord.Best_Time_To_Call__c = null;
                
                //Start Changes for CMI 2014
                caseRecord.Contact_Method__c=Null;
                caseRecord.Alternate_Phone_Number__c='';
                caseRecord.Contact_Address__c='';
                caseRecord.Alternate_Address__c='';
                caseRecord.Client_Email__c='';
                //End Changes for CMI 2014
                
                //caseRecord.Status = null;
                //caseRecord.Status_Reason__c = null;
                caseRecord.Select_the_Client_Issue_Type__c = null;
                caseRecord.If_Concierge_Select_Type__c = null;
                caseRecord.Priority = null;
                caseRecord.Submitter_s_Root_Cause__c = null;
                caseRecord.Was_Client_Satisfied_with_Resolution__c = null;
                caseRecord.Client_Comments__c = '';
                caseRecord.Resolution_Comments__c = '';
            
                // *** Coaching Needed and Tracking ***
                caseRecord.Coaching_Needed_for_the_Submitter__c = null;
                caseRecord.Was_this_a_misdirected_call__c = null;
                caseRecord.Coaching_Category__c = null;
                caseRecord.Misdirected_Call_Category__c = null;
                caseRecord.Misdirected_Call_Subcategory__c = null;
                caseRecord.Coaching_Comments__c = '';
                caseRecord.Misdirected_Call_Comments__c = '';
            }
            
            //Start commenting for CMI 2014
            //case type Complaint is not needed for CMI 2014
            /*if (caserecord.Type == 'Complaint' &&  caserecord.Account_Type__c == 'Mortgage Loan')
            {
                caseRecord.RecordTypeId = [select id from RecordType where name='Mortgage Helpline'].id;            
            }*/
            //End commenting for CMI 2014
            
            try
            {
                insert caseRecord;
                pr = new PageReference('/ThankYou');        
                pr.getParameters().put('TransferedFrom', 'Branch');
                pr.setRedirect(true); 
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        else
        {
            pr = ApexPages.currentPage();  //Return to the same page.
            pr.setRedirect(false);
        }
                   
        return pr;   
    }       
    
    /*********************************************************************************/     
    /*                       C A N C E L   O V E R R I D E                           */     
    /*********************************************************************************/    
    public PageReference cancel()     
    {
        PageReference pr = new PageReference('/CancelPage');        
        pr.getParameters().put('TransferedFrom', 'Branch');
        pr.setRedirect(true);        
        return pr;   
    }    
}