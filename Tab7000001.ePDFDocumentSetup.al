table 7000001 "ePDF Document Setup"
{

    fields
    {
        field(1; "Document Code"; Code[10])
        {
        }
        field(2; "Document Description"; Text[30])
        {
        }
        field(3; "Related Table ID"; Integer)
        {
        }
        field(4; "Related Report ID"; Integer)
        {
        }
        field(5; "Email Subject"; Text[100])
        {
        }
        field(6; "Email Body 1"; Text[250])
        {
        }
        field(7; "Email Body 2"; Text[250])
        {
        }
        field(8; "Email Body 3"; Text[250])
        {
        }
        field(9; "Email Body 4"; Text[250])
        {
        }
        field(10; "Default Path to Store PDF"; Text[250])
        {
        }
        field(11; "Use Batch Processing"; Boolean)
        {
            trigger OnValidate();
            var
                ePDFSetup: Record "ePDF Setup";
            begin
                ePDFSetup.GET;
                IF("Use Batch Processing" = FALSE) AND("Document Code" IN [ePDFSetup."Posted Purchase Receipt",
                                                             ePDFSetup."Posted Purchase Invoice",
                                                             ePDFSetup."Posted Purch Return Shipment",
                                                             ePDFSetup."Posted Purch Credit Memo",
                                                             ePDFSetup."Posted Sales Shipment",
                                                             ePDFSetup."Posted Sales Invoice",
                                                             ePDFSetup."Posted Sales Return Receipt",
                                                             ePDFSetup."Posted Sales Credit Memo"]) THEN
                    ERROR('Use Batch Processing can not be FALSE if the document is configured in any of the posted documents in ePDFSetup.');

            end;
        }
        field(12; "Enable"; Boolean)
        {
        }
        field(14; "Alternate Report ID"; Integer)
        {
            trigger OnValidate();
            var
                ePDFSetup: Record "ePDF Setup";
            begin
                ePDFSetup.GET;
                IF "Document Code" <> ePDFSetup."Remittance Advice" THEN
                    ERROR('Alternate Report ID is applicable only for the document configured as Remittance Advice in ePDFSetup.');
            end;
        }

    }

    keys
    {
        key(PK; "Document Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;
}
