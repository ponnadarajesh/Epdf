pageextension 7000032 epdfPostedRR extends "Posted Return Receipt"
{
    
    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action("&ePDF Email Sales Return Receipt")
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
                    IF (ePDFSetup."Posted Sales Return Receipt"<> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Posted Sales Return Receipt", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Posted Sales Return Receipt Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
