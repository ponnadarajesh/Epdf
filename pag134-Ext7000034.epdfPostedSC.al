pageextension 7000034 epdfPostedSC extends "Posted Sales Credit Memo"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("&Cr. Memo")
        {
            action("&ePDF Email Sales Credit Memo")
            {
                Image = SendEmailPDF;
                ApplicationArea = All;                
                trigger OnAction();
                var
                    ePDFSetup:Record "ePDF Setup";
                    Cust :Record Customer;
                    EmailSent:Boolean;
                    QueueCreated:Boolean;
                    ePDF: Codeunit "ePDF Management";
                begin
                    ePDFSetup.GET;
                    Cust.GET("Sell-to Customer No.");
                    IF (ePDFSetup."Posted Sales Credit Memo"<> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Posted Sales Credit Memo", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Posted Sales Credit Memo Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
