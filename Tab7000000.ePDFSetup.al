table 7000000 "ePDF Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "Sender Email ID"; Text[100])
        {

        }
        field(3; "Sender Name"; Text[50])
        {

        }
        field(4; "Use PDF Printer"; Boolean)
        {
            Trigger OnValidate();
            Begin
                IF "Use PDF Printer" = TRUE THEN
                    IF "PDF Printer" = '' THEN
                        ERROR('Please define PDF Printer first');
            End;
        }
        field(5; "PDF Printer"; Text[50])
        {
            Trigger OnValidate();
            Begin
                IF "Use PDF Printer" = TRUE THEN
                    IF "PDF Printer" = '' THEN
                        ERROR('Please uncheck Use PDF Printer first.');
            End;
        }
        field(6; "CC Email to Sender"; Boolean)
        {

        }
        field(100; "Customer Statement"; Code[10])
        {

        }
        field(101; "Purchase Order"; Code[10])
        {

        }
        field(102; "Purchase Invoice"; Code[10])
        {

        }
        field(103; "Purchase Quote"; Code[10])
        {

        }
        field(104; "Purchase Return Order"; Code[10])
        {

        }
        field(105; "Posted Purchase Receipt"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Purchase Receipt" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Purchase Receipt");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(106; "Posted Purchase Invoice"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Purchase Invoice" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Purchase Invoice");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(107; "Posted Purch Return Shipment"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Purch Return Shipment" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Purch Return Shipment");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(108; "Posted Purch Credit Memo"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Purch Credit Memo" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Purch Credit Memo");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(109; "Sales Order"; Code[10])
        {

        }
        field(110; "Sales Invoice"; Code[10])
        {

        }
        field(111; "Sales Quote"; Code[10])
        {

        }
        field(112; "Sales Return Order"; Code[10])
        {

        }
        field(113; "Posted Sales Shipment"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Sales Shipment" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Sales Shipment");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(114; "Posted Sales Invoice"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Sales Invoice" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Sales Invoice");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(115; "Posted Sales Return Receipt"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Sales Return Receipt" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Sales Return Receipt");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(116; "Posted Sales Credit Memo"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Sales Credit Memo" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Sales Credit Memo");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;
        }
        field(117; "Remittance Advice"; Code[10])
        {

        }
        field(118; "Issued Finance Charge"; Code[10])
        {

        }
        field(119; "Issued Reminder"; Code[10])
        {

        }
        field(120; "Transfer Order"; Code[10])
        {

        }
        field(121; "Vendor Statement"; Code[10])
        {

        }
        field(122; "Posted Service Sales Invoice"; Code[10])
        {
            Trigger OnValidate();
            var
                ePDFDocSetup: Record "ePDF Document Setup";
            begin
                IF "Posted Service Sales Invoice" <> '' THEN BEGIN
                    ePDFDocSetup.GET("Posted Service Sales Invoice");
                    ePDFDocSetup.TESTFIELD("Use Batch Processing", TRUE);
                END;
            end;

        }
        field(300; "Stmt Print All With Entries"; Boolean)
        {

        }
        field(301; "Stmt Print All With Balance"; Boolean)
        {

        }
        field(302; "Stmt Update Statement No"; Boolean)
        {

        }
        field(303; "Stmt Print Company Address"; Boolean)
        {

        }
        field(304; "Stmt Print in LCY"; Boolean)
        {

        }
        field(305; "Stmt Statement Style"; Option)
        {
            OptionMembers = "Open Item", Balance;
        }
        field(306; "Stmt Aged By"; Option)
        {
            Optionmembers = None, "Due Date", "Trans Date", "Doc Date";
        }
        field(307; "Stmt Date Filter"; Text[30])
        {

        }
        field(308; "V Stmt Print All With Entries"; Boolean)
        {

        }
        field(309; "V Stmt Print All With Balance"; Boolean)
        {

        }
        field(310; "V Stmt Update Statement No"; Boolean)
        {

        }
        field(311; "V Stmt Print Company Address"; Boolean)
        {

        }
        field(312; "V Stmt Print in LCY"; Boolean)
        {

        }
        field(313; "V Stmt Statement Style"; Option)
        {
            OptionMembers = "Open Item", Balance;
        }
        field(314; "V Stmt Aged By"; Option)
        {
            OptionMembers = None, "Due Date", "Trans Date", "Doc Date";
        }
        field(315; "V Stmt Date Filter"; Text[30])
        {

        }
        field(316; "Stmt Length of Aging Period"; Code[10])
        {

        }
        field(317; "V Stmt Length of Aging Period"; Code[10])
        {

        }

    }

    keys
    {
        key(PK; "Primary Key")
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