pageextension 7000026 epdfPostedPI extends "Posted Purchase Invoice"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("Actions")
        {
            action("&ePDF Email Posted Purchase Invoice")
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
                    IF (ePDFSetup."Posted Purchase Invoice" <> '' ) AND Vend."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Posted Purchase Invoice", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Posted Purchase Invoice Document not setup in ePDF Setup OR ePDF not enabled for this Vendor.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
