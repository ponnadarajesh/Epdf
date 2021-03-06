pageextension 7000019 epdfSalesInvoice extends "Sales Invoice"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("&Invoice")
        {
           
            action("&ePDF Email Sales Invoice")
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
                    IF (ePDFSetup."Sales Invoice" <> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Sales Invoice", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Sales Invoice Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
