table 7000004 "ePDF Email Address"
{

    fields
    {
        field(1; "Document Code"; Code[10])
        {
        }
        field(2; "Entity Type"; Option)
        {
            OptionMembers = Customer, Vendor, Location, Company;
        }
        field(3; "Entity No."; Code[20])
        {
        }
        field(4; "Address Type"; Option)
        {
            OptionMembers = To, Cc, Bcc;
        }
        field(5; Address; Text[100])
        {
        }

    }

    keys
    {
        key(PK; "Document Code", "Entity Type", "Entity No.", "Address Type")
        {
            Clustered = true;
        }
    }

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
