pageextension 7000014 ePDFCustList extends "Customer List"
{
    actions
    {
        AddLast("&Customer")
        {
            action("&ePDF Email Customer Statement")
            {
                Image = SendEmailPDF;
                ApplicationArea = All;
                trigger OnAction();
                var
                    ePDFSetup: Record "ePDF Setup";
                    ePDF: Codeunit "ePDF Management";
                    Cust: Record Customer;
                    EmailSent: Boolean;
                    FiltersText: text[250];
                    QueueCreated: Boolean;
                begin
                    ePDFSetup.GET;
                    IF ePDFSetup."Customer Statement" <> '' THEN BEGIN
                        Cust.COPY(Rec);
                        FiltersText := Cust.GETFILTERS;
                        IF Cust.FINDSET AND CONFIRM('Do you wish to send statements for date %1 to customers with following filters: \%2', TRUE, ePDFSetup."Stmt Date Filter", FiltersText) THEN BEGIN
                            REPEAT
                            IF Cust."ePDF Email" THEN BEGIN
                                EmailSent := ePDF.SendDocument(ePDFSetup."Customer Statement", Cust."No.");
                                QueueCreated := TRUE;
                            END;
                            UNTIL Cust.NEXT = 0;

                            IF EmailSent THEN
                                MESSAGE('ePDF Email has been sent for customers which have ePDF Email enabled.')
                            ELSE
                                MESSAGE('ePDF Email Queue has been created for customers which have ePDF Email enabled.');
                        END;
                    END ELSE
                        ERROR('Customer Statement Document not setup in ePDF Setup.');
                end;
            }

        }
        // Add changes to page actions here
    }
}