CREATE PROCEDURE [Corp].[st_UpdateReportExRatesConfigXML]
   @XML AS XML = NULL
AS
   DECLARE @Id_Report int,
         @ValueIn int

   DECLARE @t TABLE (Id INT IDENTITY(1,1), IdRep INT, ValueIn INT)
   DECLARE @Id int = null

   IF (@XML IS NOT NULL)
   BEGIN
      INSERT INTO @t
      SELECT
         batch.element.value('IdReport[1]', 'VARCHAR(10)'),
         batch.element.value('ValueIn[1]', 'VARCHAR(10)')
      FROM @XML.nodes('/Root/SingleElement') batch(element)

      WHILE (SELECT COUNT(1) FROM @t)>0
      BEGIN
         SELECT TOP 1 @Id = Id, @Id_Report = IdRep, @ValueIn = ValueIn FROM @t
         UPDATE ReportExRatesConfig SET ValueIn=@ValueIn WHERE Id_Report=@Id_Report
         DELETE FROM @t WHERE Id = @Id
      END
   END
   ELSE
   BEGIN
      PRINT 'XML MAL FORMADO'
   END
   
