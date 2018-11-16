pageextension 7000023 epdfPostedSS extends "Posted Sales Shipment"
{
    
    actions
    {
        // Add changes to page actions here
        addlast("&Shipment")
        {
            action("&ePDF Email Sales Shipment")
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
                    IF (ePDFSetup."Posted Sales Shipment"<> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Posted Sales Shipment", "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Posted Sales Shipment Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
