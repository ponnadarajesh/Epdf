pageextension 7000016 ePDFVendList extends "Vendor List"
{
    actions
    {
        AddLast("Ven&dor")
        {
            action("&ePDF Email Vendor Statement")
            {
                Image = SendEmailPDF;
                ApplicationArea = All;               
                trigger OnAction();
                var
                    ePDFSetup: Record "ePDF Setup";
                    ePDF: Codeunit "ePDF Management";
                    recVendor: Record Vendor;
                    EmailSent: Boolean;
                    FiltersText: text[250];
                    QueueCreated: Boolean;
                begin
                    ePDFSetup.GET;
                    IF ePDFSetup."Vendor Statement" <> '' THEN BEGIN
                        recVendor.COPY(Rec);
                        FiltersText := recVendor.GETFILTERS;
                        IF recVendor.FINDSET AND CONFIRM('Do you wish to send statements for date %1 to Vendors with following filters: \%2', TRUE, ePDFSetup."Stmt Date Filter", FiltersText) THEN BEGIN
                            REPEAT
                            IF recVendor."ePDF Email" THEN BEGIN
                                EmailSent := ePDF.SendDocument(ePDFSetup."Vendor Statement", recVendor."No.");
                                QueueCreated := TRUE;
                            END;
                            UNTIL recVendor.NEXT = 0;

                            IF EmailSent THEN
                                MESSAGE('ePDF Email has been sent for Vendors which have ePDF Email enabled.')
                            ELSE
                                MESSAGE('ePDF Email Queue has been created for Vendors which have ePDF Email enabled.');
                        END;
                    END ELSE
                        ERROR('Vendor Statement Document not setup in ePDF Setup.');
                end;
            }

        }
        // Add changes to page actions here
    }
}