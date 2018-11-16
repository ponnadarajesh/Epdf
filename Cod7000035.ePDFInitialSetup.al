codeunit 7000035 ePDFInitialSetup
{
    // Set the codeunit to be an install codeunit. 
    Subtype = Install;
    
    // This trigger includes code for company-related operations. 
    trigger OnInstallAppPerCompany();
    var
        ePDFSetup : Record "ePDF Setup";
        ePDFDocSetup : Record "ePDF Document Setup";
    begin
        // If the table is empty, insert the default values.
        if ePDFDocSetup.IsEmpty() then begin
            Insert_eDocSetup();
        end;
        if ePDFSetup.IsEmpty() then begin
            Insert_ePDFSetup();
        end; 
        //EnableEpdf_Customers();
        //EnableEpdf_Vendors()       
    end;

    
    procedure Insert_eDocSetup();
    begin
        //Insert purchase Quote code
        Insert_eDocs('PURCHQUOTE','Purchase Quote',0,0,'C:\PDF\',true,true,0);
        //Insert purchase order code
        Insert_eDocs('PURCHORDER','Purchase Order',0,0,'C:\PDF\',true,true,0);
        //Insert purchase Invoice code
        Insert_eDocs('PURCHINV','Purchase Invoice',0,0,'C:\PDF\',true,true,0);
        //Insert Purchase Return Order
        Insert_eDocs('PURCHRTORD','Purchase Return Order',0,0,'C:\PDF\',true,true,0);
        //Posted Purchase Receipt
        Insert_eDocs('PURCHRCPT','Purchase Receipt',0,0,'C:\PDF\',true,true,0);
        //Posted Purchase Invoice
        Insert_eDocs('PPURCHINV','Posted Purchase Invoice',0,0,'C:\PDF\',true,true,0);
        //Posted Purch Return Shipment
        Insert_eDocs('POSTRETSHP','Purchase Return shipment',0,0,'C:\PDF\',true,true,0);
        //Posted Purch Credit Memo
        Insert_eDocs('PPURCHCR','Posted Purchase Credit',0,0,'C:\PDF\',true,true,0);
        //Sales Quote
        Insert_eDocs('SALESQUOTE','Sales Quote',0,0,'C:\PDF\',true,true,0);       
        //Sales Order
        Insert_eDocs('SALESORDER','Sales Order',0,0,'C:\PDF\',true,true,0);
        //Sales Invoice
        Insert_eDocs('SALESINV','Sales Invoice',0,0,'C:\PDF\',true,true,0);
        //Sales Return Order
        Insert_eDocs('SALESRTORD','Posted sales Return order',0,0,'C:\PDF\',true,true,0);
        //Posted Sales Shipment
        Insert_eDocs('PSALESSHIP','Posted sales shipment',0,0,'C:\PDF\',true,true,0);
        //Posted Sales Invoice
        Insert_eDocs('PSALESINV','Posted sales Invoice',0,0,'C:\PDF\',true,true,0);
        //Posted Sales Return Receipt
        Insert_eDocs('PSALESRTRC','Posted Sales Return receipt',0,0,'C:\PDF\',true,true,0);
        //Posted Sales Credit Memo
        Insert_eDocs('PSALESCR','Posted Sales Credit Memo',0,0,'C:\PDF\',true,true,0);
        //Remittance Advice
        Insert_eDocs('REMITADV','Remittance Advice',0,0,'C:\PDF\',true,true,0);
        //Issued Finance Charge
        Insert_eDocs('ISSUEFINCH','Issued Fin Charge',0,0,'C:\PDF\',true,true,0);
        //Issued Reminder
        Insert_eDocs('ISSUEDREM','Issue Reminder',0,0,'C:\PDF\',true,true,0);
        //Transfer Order
        Insert_eDocs('TRANSERORD','Transfer Order',0,0,'C:\PDF\',true,true,0);
        //Vendor Statement
        Insert_eDocs('VSTATE','Vendor Statement',0,0,'C:\PDF\',true,true,0);
        //Vendor Statement
        Insert_eDocs('CSTATE','Customer statement',0,0,'C:\PDF\',true,true,0);
        
    end;

    procedure Insert_eDocs(pDocCode:Code[10];pDocDesc:text[30];pRelatedTableID:Integer;pRelatedReportID:Integer;pDefaultPathtoStorePDF:text[250];pUseBatchProcessing:Boolean;penable:Boolean;pAlternateReportID:Integer);
    var
        ePDFDocSetup : Record "ePDF Document Setup";
    begin
        with ePDFDocSetup do begin
        Init();
        "Document Code" := pDocCode;
        "Document Description" := pDocDesc;
        "Related Table ID" := pRelatedTableID;
        "Related Report ID" := pRelatedReportID;
        "Default Path to Store PDF" := pDefaultPathtoStorePDF; 
        "Use Batch Processing" := pUseBatchProcessing;
        Enable := penable;
        "Alternate Report ID" := pAlternateReportID;
        Insert();
        End;
    end;
    procedure Insert_ePDFSetup()
    var
        lePDFSetup: Record "ePDF Setup";
    begin
        With lePDFSetup DO begin
            Init();
            "Primary Key" := '';
            //"Sender Email ID" := 
            //"Sender Name":=
            //"Use PDF Printer":=
            //"PDF Printer":=
            //"CC Email to Sender":=
            "Customer Statement":= 'CSTATE';
            "Purchase Order":= 'PURCHORDER';
            "Purchase Invoice":='PURCHINV';
            "Purchase Quote":='PURCHQUOTE';
            "Purchase Return Order":='PURCHRTORD';
            "Posted Purchase Receipt" := 'PURCHRCPT';
            "Posted Purchase Invoice":= 'PPURCHINV';
            "Posted Purch Return Shipment":= 'POSTRETSHP';
            "Posted Purch Credit Memo":='PPURCHCR';
            "Sales Order":= 'SALESORDER';
            "Sales Invoice":='SALESINV';
            "Sales Quote":='SALESQUOTE';
            "Sales Return Order":='SALESRTORD';
            "Posted Sales Shipment":= 'PSALESSHIP';
            "Posted Sales Invoice":= 'PSALESINV';
            "Posted Sales Return Receipt":= 'PSALESRTRC';
            "Posted Sales Credit Memo":= 'PSALESCR';
            "Remittance Advice":= 'REMITADV';
            "Issued Finance Charge":= 'ISSUEFINCH';
            "Issued Reminder":= 'ISSUEDREM';
            "Transfer Order":= 'TRANSERORD';
            "Vendor Statement":= 'VSTATE';
/*             "Posted Service Sales Invoice":=
            "Stmt Print All With Entries":=
            "Stmt Print All With Balance":=
            "Stmt Update Statement No":=
            "Stmt Print Company Address":=
            "Stmt Print in LCY":=
            "Stmt Statement Style":=
            "Stmt Aged By":=
            "Stmt Date Filter":=
            "V Stmt Print All With Entries":=
            "V Stmt Print All With Balance":=
            "V Stmt Update Statement No":=
            "V Stmt Print Company Address":=
            "V Stmt Print in LCY":=
            "V Stmt Statement Style":=
            "V Stmt Aged By":=
            "V Stmt Date Filter":=
            "Stmt Length of Aging Period":=
            "V Stmt Length of Aging Period":=
*/        
            insert();
        end;
    end;

}