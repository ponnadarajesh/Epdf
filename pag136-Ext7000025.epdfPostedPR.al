pageextension 7000025 epdfPostedPR extends "Posted Purchase Receipt"
{
    
    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action("&ePDF Email Posted Purchase Receipt")
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
                    IF (ePDFSetup."Posted Purchase Receipt" <> '' ) AND Vend."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Posted Purchase Receipt", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Posted Purchase Receipt Document not setup in ePDF Setup OR ePDF not enabled for this Vendor.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
