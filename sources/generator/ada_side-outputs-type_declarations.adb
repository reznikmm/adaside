package body Ada_Side.Outputs.Type_Declarations is

   --------------
   -- Document --
   --------------

   overriding function Document
    (Self    : Type_Declaration;
     Printer : not null access League.Pretty_Printers.Printer'Class;
     Pad     : Natural)
      return League.Pretty_Printers.Document
   is
      pragma Unreferenced (Pad);
      Result : League.Pretty_Printers.Document := Printer.New_Document;
   begin
      Result.New_Line;
      Result.Put ("type ");
      Result.Append (Self.Name.Document (Printer, 0));

      if Self.Discriminants /= null then
         Result.Put (" (");
         Result.Append (Self.Discriminants.Document (Printer, 0));
         Result.Put (")");
      end if;

      if Self.Definition /= null then
         Result.Put (" is ");
         Result.Append (Self.Definition.Document (Printer, 0));
      end if;

      Result.Append (Print_Aspect (Self.Aspects, Printer));
      Result.Put (";");

      return Result;
   end Document;

   --------------
   -- New_Type --
   --------------

   function New_Type
     (Name          : not null Node_Access;
      Discriminants : Node_Access;
      Definition    : Node_Access;
      Aspects       : Node_Access;
      Comment       : League.Strings.Universal_String)
      return Node'Class
   is
   begin
      return Type_Declaration'
        (Name,
         Discriminants,
         Definition,
         Aspects,
         Comment);
   end New_Type;

end Ada_Side.Outputs.Type_Declarations;
