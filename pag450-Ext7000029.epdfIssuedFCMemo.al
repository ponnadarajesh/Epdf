pageextension 7000029 epdfIssuedFCMemo extends "Issued Finance Charge Memo"
{
    
    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action("&ePDF Email Issued Finance Charge Memo")
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
                    Cust.GET("Customer No.");
                    IF (ePDFSetup."Issued Finance Charge" <> '' ) AND Cust."ePDF Email" THEN BEGIN
                        EmailSent := ePDF.SendDocument(ePDFSetup."Issued Finance Charge" , "No.");
                        QueueCreated := TRUE;
                    END ELSE
                        ERROR('Issued Finance Charge not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                    IF EmailSent THEN
                        MESSAGE('ePDF Email has been sent.')
                    ELSE
                        MESSAGE('ePDF Email Queue has been created.');
                end;
            }
               
        }
    }
     
}
