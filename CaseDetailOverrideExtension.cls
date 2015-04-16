public class CaseDetailOverrideExtension
{
    private final Case record;
    private Case m_caseDetail;
    private string m_recordTypeName;   
    
    //start changes for CMI 2014
    //variable to store CIN coming in URL.
    private string CIN;
    //property store CIN.
    public String clientCIN
    {
        get
        {
            return CIN;    
        }
    }
    //variable to store 'archived' parameter coming in URL.
    private string archived;
    //property store 'archived' parameter.
    public String archivedFlow
    {
        get
        {
            return archived;    
        }
    }    
    //end changes for CMI 2014
    
    public CaseDetailOverrideExtension(ApexPages.StandardController caseController)
    {
        record = (Case)caseController.getRecord();
        CIN=ApexPages.currentPage().getParameters().get('cin');
        archived=ApexPages.currentPage().getParameters().get('archived');
    }
    
    public void Page_Load()
    {
        m_caseDetail = [select id, recordtypeid, SLA_Start__c, SLA_End__c from Case where id = :record.id];
        m_recordTypeName = [select name from recordtype 
                            where SObjectType = 'Case' and 
                            isActive = true and 
                            id = :m_caseDetail.recordtypeid].name;
    }
    
    public string RecordTypeName
    {
        get{ return m_recordTypeName; }
    }
    
    public string TimeRemaining
    {
        get
        {
            BusinessHours bh = [select id from businesshours where IsDefault=true];
            return string.valueOf(BusinessHours.diff(bh.id, System.now(), m_caseDetail.SLA_End__c )/60000);
        }
    }
    
}