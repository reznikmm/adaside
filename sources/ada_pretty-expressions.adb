--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package body Ada_Pretty.Expressions is

   --------------
   -- Document --
   --------------

   overriding function Document
     (Self    : Apply;
      Printer : not null access League.Pretty_Printers.Printer'Class;
      Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      --  Format this as
      --  Prefix
      --    (Arguments)
      pragma Unreferenced (Pad);
      Prefix : League.Pretty_Printers.Document :=
        Self.Prefix.Document (Printer, 0);
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.New_Line;
      Result.Put ("(");
      Result.Append (Self.Arguments.Document (Printer, 0).Nest (1));
      Result.Put (")");
      Result.Nest (2);
      Prefix.Append (Result);
      Prefix.Group;

      return Prefix;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Self    : Qualified;
      Printer : not null access League.Pretty_Printers.Printer'Class;
      Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      --  Format this as Prefix'(Arguments) or
      --  Prefix'
      --    (Arguments)
      pragma Unreferenced (Pad);
      Prefix : League.Pretty_Printers.Document :=
        Self.Prefix.Document (Printer, 0);
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.New_Line (Gap => "");
      Result.Put ("(");
      Result.Append (Self.Argument.Document (Printer, 0).Nest (1));
      Result.Put (")");
      Result.Nest (2);
      Prefix.Put ("'");
      Prefix.Append (Result);
      Prefix.Group;

      return Prefix;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : Component_Association;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      if Self.Choices /= null then
         Result.Append (Self.Choices.Document (Printer, Pad));
         Result.Put (" =>");
         Result.New_Line;
         Result.Append (Self.Value.Document (Printer, Pad));
         Result.Nest (2);
         Result.Group;
      else
         Result.Append (Self.Value.Document (Printer, Pad));
      end if;

      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : If_Expression;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      Result : League.Pretty_Printers.Document := Printer.New_Document;
      Then_Part : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.Put ("if ");
      Result.Append (Self.Condition.Document (Printer, Pad));
      Then_Part.New_Line;
      Then_Part.Put ("then ");
      Then_Part.Append (Self.Then_Path.Document (Printer, Pad));
      Then_Part.Nest (2);
      Result.Append (Then_Part);

      if Self.Elsif_List /= null then
         declare
            Elsif_Part : League.Pretty_Printers.Document :=
              Printer.New_Document;
         begin
            Elsif_Part.Append (Self.Elsif_List.Document (Printer, Pad));
            Elsif_Part.Nest (2);
            Result.New_Line;
            Result.Append (Elsif_Part);
         end;
      end if;

      if Self.Else_Path /= null then
         declare
            Else_Part : League.Pretty_Printers.Document :=
              Printer.New_Document;
         begin
            Else_Part.Put ("else ");
            Else_Part.Append (Self.Else_Path.Document (Printer, Pad));
            Else_Part.Nest (2);
            Result.New_Line;
            Result.Append (Else_Part);
         end;
      end if;

      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Self    : Infix;
      Printer : not null access League.Pretty_Printers.Printer'Class;
      Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.New_Line;
      Result.Put (Self.Operator);
      Result.Put (" ");
      Result.Append (Self.Left.Document (Printer, Pad));
      Result.Nest (2);
      Result.Group;

      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
     (Self    : Integer_Literal;
      Printer : not null access League.Pretty_Printers.Printer'Class;
      Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      pragma Unreferenced (Pad);

      Image : constant Wide_Wide_String :=
        Natural'Wide_Wide_Image (Self.Value);
   begin
      return Printer.New_Document.Put (Image (2 .. Image'Last));
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : Name;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural) return League.Pretty_Printers.Document
   is
      Result  : League.Pretty_Printers.Document := Printer.New_Document;
      Padding : constant Wide_Wide_String
        (Self.Name.Length + 1 .. Pad) := (others => ' ');
   begin
      Result.Put (Self.Name);

      if Padding'Length > 0 then
         Result.Put (Padding);
      end if;

      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : Parentheses;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      pragma Unreferenced (Pad);
      Result  : League.Pretty_Printers.Document := Printer.New_Document;
      Child   : constant League.Pretty_Printers.Document :=
        Self.Child.Document (Printer, 0);
   begin
      Result.Put ("(");
      Result.Append (Child.Nest (1));
      Result.Put (")");

      return Result;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : Selected_Name;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      pragma Unreferenced (Pad);
      --  Format this as
      --  Prefix
      --    .Selector
      Result : League.Pretty_Printers.Document := Printer.New_Document;
      Prefix : League.Pretty_Printers.Document :=
        Self.Prefix.Document (Printer, 0);
      Selector : constant League.Pretty_Printers.Document :=
        Self.Selector.Document (Printer, 0);
   begin
      Result.New_Line (Gap => "");
      Result.Put (".");
      Result.Append (Selector);
      Result.Nest (2);
      Result.Group;
      Prefix.Append (Result);
      return Prefix;
   end Document;

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : String;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      pragma Unreferenced (Pad);
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.Put ("""");
      Result.Put (Self.Text);
      Result.Put ("""");
      return Result;
   end Document;

   ----------
   -- Join --
   ----------

   overriding function Join
    (Self    : Component_Association;
     List    : Node_Access_Array;
     Pad     : Natural;
     Printer : not null access League.Pretty_Printers.Printer'Class)
      return League.Pretty_Printers.Document
   is
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.Append (Self.Document (Printer, Pad));

      for J in List'Range loop
         declare
            Next : League.Pretty_Printers.Document := Printer.New_Document;
         begin
            Next.Put (",");
            Next.New_Line;
            Next.Append (List (J).Document (Printer, Pad));
            Next.Group;
            Result.Append (Next);
         end;
      end loop;

      return Result;
   end Join;

   overriding function Max_Pad (Self : Argument_Association) return Natural is
   begin
      if Self.Choices = null then
         return 0;
      else
         return Self.Choices.Max_Pad;
      end if;
   end Max_Pad;

   ---------------
   -- New_Apply --
   ---------------

   function New_Apply
     (Prefix    : not null Node_Access;
      Arguments : not null Node_Access) return Node'Class is
   begin
      return Apply'(Prefix, Arguments);
   end New_Apply;

   ------------------------------
   -- New_Argument_Association --
   ------------------------------

   function New_Argument_Association
     (Choice : Node_Access;
      Value  : not null Node_Access) return Node'Class is
   begin
      return Argument_Association'(Choice, Value);
   end New_Argument_Association;

   -------------------------------
   -- New_Component_Association --
   -------------------------------

   function New_Component_Association
     (Choices : Node_Access;
      Value   : not null Node_Access) return Node'Class is
   begin
      return Component_Association'(Choices, Value);
   end New_Component_Association;

   ------------
   -- New_If --
   ------------

   function New_If
     (Condition  : not null Node_Access;
      Then_Path  : not null Node_Access;
      Elsif_List : Node_Access;
      Else_Path  : Node_Access) return Node'Class is
   begin
      return If_Expression'(Condition, Then_Path, Elsif_List, Else_Path);
   end New_If;

   ---------------
   -- New_Infix --
   ---------------

   function New_Infix
     (Operator : League.Strings.Universal_String;
      Left     : not null Node_Access)
      return Node'Class is
   begin
      return Infix'(Operator, Left);
   end New_Infix;

   -----------------
   -- New_Literal --
   -----------------

   function New_Literal
     (Value : Natural; Base  : Positive) return Node'Class is
   begin
      return Integer_Literal'(Value, Base);
   end New_Literal;

   --------------
   -- New_Name --
   --------------

   function New_Name (Name : League.Strings.Universal_String)
     return Node'Class is
   begin
      return Expressions.Name'(Name => Name);
   end New_Name;

   ---------------------
   -- New_Parentheses --
   ---------------------

   function New_Parentheses
     (Child : not null Node_Access) return Node'Class is
   begin
      return Expressions.Parentheses'(Child => Child);
   end New_Parentheses;

   -------------------
   -- New_Qualified --
   -------------------

   function New_Qualified
     (Prefix   : not null Node_Access;
      Argument : not null Node_Access) return Node'Class is
   begin
      return Expressions.Qualified'(Prefix, Argument);
   end New_Qualified;

   -----------------------
   -- New_Selected_Name --
   -----------------------

   function New_Selected_Name
     (Prefix   : not null Node_Access;
      Selector : not null Node_Access) return Node'Class is
   begin
      return Selected_Name'(Prefix, Selector);
   end New_Selected_Name;

   ----------------
   -- New_String --
   ----------------

   function New_String (Text : League.Strings.Universal_String)
      return Node'Class is
   begin
      return String'(Text => Text);
   end New_String;

end Ada_Pretty.Expressions;
