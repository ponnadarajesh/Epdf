table 7000003 "ePDF History"
{

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Document Code"; Code[10])
        {
        }
        field(3; "Document No."; Code[20])
        {
        }
        field(4; Description; Text[50])
        {
        }
        field(5; "Date Logged"; Date)
        {
        }
        field(6; "Time Logged"; Time)
        {
        }
        field(7; "Logged By"; Code[50])
        {
        }
        field(8; "Retry Attempt"; Integer)
        {
        }
        field(9; "PDF Path"; Text[50])
        {
        }
        field(10; "Date Processed"; Date)
        {
        }
        field(11; "Time Processed"; Time)
        {
        }
        field(12; "Processed By"; Code[50])
        {
        }
        field(20; "Entity Type"; Option)
        {
            OptionMembers = Customer, Vendor, Location;
        }
        field(21; "Entity No."; Code[20])
        {
        }

    }

    keys
    {
        key(PK; "Entry No.")
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
