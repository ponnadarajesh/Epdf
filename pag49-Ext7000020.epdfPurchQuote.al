pageextension 7000020 epdfPurchQuote extends "Purchase Quote"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("&Quote")
        {
            action("&ePDF Email Purchase Quote")
            {
                Image = SendEmailPDF;
                ApplicationArea = All;
                trigger OnAction();
                var
                    ePDFSetup:Record "ePDF Setup";
                    Vend :Record Vendor;
                    EmailSent:Boolean;
                    QueueCreated:Boolean;
                    ePDF: Codeunit "ePDF Management";
                begin
                    ePDFSetup.GET;
                    Vend.GET("Buy-from Vendor No.");
                    IF (ePDFSetup."Purchase Quote" <> '' ) AND Vend."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Purchase Quote", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Purchase Quote Document not setup in ePDF Setup OR ePDF not enabled for this Vendor.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
