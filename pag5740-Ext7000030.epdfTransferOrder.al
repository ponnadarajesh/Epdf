pageextension 7000030 epdfTransferOrder extends "Transfer Order"
{
    
    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action("&ePDF Email Transfer Order")
            {
                Image = SendEmailPDF;
                ApplicationArea = All;                
                trigger OnAction();
                var
                    ePDFSetup:Record "ePDF Setup";
                    Loc :Record Location;
                    EmailSent:Boolean;
                    QueueCreated:Boolean;
                    ePDF: Codeunit "ePDF Management";
                begin
                    ePDFSetup.GET;
                    Loc.GET("Transfer-to Code");
                    IF (ePDFSetup."Transfer Order" <> '' ) AND (Loc."ePDF Receipt Email ID"<>'') THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Transfer Order", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Transfer order Document not setup in ePDF Setup OR ePDF not enabled for this Vendor.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
