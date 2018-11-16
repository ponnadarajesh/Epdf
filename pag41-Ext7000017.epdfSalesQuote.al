pageextension 7000017 epdfSalesQuote extends "Sales Quote"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("&Quote")
        {
            action("&ePDF Email Sales Quote")
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
                    IF (ePDFSetup."Sales Quote" <> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Sales Quote", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Sales Quote Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
