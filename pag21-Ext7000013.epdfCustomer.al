pageextension 7000013 epdfCustomer extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            group(ePDF)
            {
                // Add changes to page layout here
                field("ePDF Email";"ePDF Email")
                {
                    ApplicationArea = All;
                    Caption = 'ePDF Email';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(Creation)
        {
            group(function)
            {
               Action("&ePDF Email Customer Statement")     
               {
                    ApplicationArea = All;
                    Image = SendEmailPDF;
                    trigger OnAction();
                    var
                        ePDFSetup :record "ePDF Setup";
                        EmailSent :Boolean;
                        QueueCreated :Boolean;
                        ePDF:Codeunit "ePDF Management";
                    begin
                        ePDFSetup.GET;
                        IF (ePDFSetup."Customer Statement" <> '') AND "ePDF Email" THEN BEGIN
                            EmailSent := ePDF.SendDocument(ePDFSetup."Customer Statement", "No.");
                            QueueCreated := TRUE;
                        END ELSE
                            ERROR('Customer Statement Document not setup in ePDF Setup OR ePDF not enabled for this Customer.');

                        IF EmailSent THEN
                            MESSAGE('ePDF Email has been sent.')
                        ELSE
                            MESSAGE('ePDF Email Queue has been created.');
                    end;
    
               }
            }
        }
    }
       
}