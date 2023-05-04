CREATE PROCEDURE [Corp].[st_GetServicesAndProviders]
	-- Add the parameters for the stored procedure here
	
	
	/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Get TRansfer Other Products</Description>

<ChangeLog>
<log Date="01/02/2018" Author="amoreno"> Se quita el Hardcode para realizar select a  una tabla creada para este proceso</log>

</ChangeLog>
*********************************************************************/ 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/*
    -- Insert statements for procedure here
	DECLARE @TemTable TABLE(
		[ServiceId] INT,
		[ServiceName] NVARCHAR(MAX),
		[ProviderId] INT,
		[ProviderName] NVARCHAR(MAX)
		)

	-- Bill Payments
	INSERT INTO @TemTable VALUES (2, 'Bill Payments', 5, 'Regalii')
	INSERT INTO @TemTable VALUES (2, 'Bill Payments', 1, 'Softgate')
	INSERT INTO @TemTable VALUES (2, 'Bill Payments', 8, 'Fidelity Express')
	
	-- Long Distance
	INSERT INTO @TemTable VALUES (3, 'Long Distance', 3, 'Lunex')
	INSERT INTO @TemTable VALUES (3, 'Long Distance', 4, 'Pure Minutes')

	-- Top Ups
	INSERT INTO @TemTable VALUES (4, 'Top Ups', 3, 'Lunex')
	INSERT INTO @TemTable VALUES (4, 'Top Ups', 5, 'Regalii')
	INSERT INTO @TemTable VALUES (4, 'Top Ups', 2, 'TransferTo')

	-- Others
	INSERT INTO @TemTable VALUES (6, 'Others', 3, 'Lunex')
	INSERT INTO @TemTable VALUES (6, 'Others', 6, 'Others')

	-- Checkes
	INSERT INTO @TemTable VALUES (7, 'Checks', 0, '');

	SELECT [ServiceId], [ServiceName], [ProviderId], [ProviderName] FROM @TemTable

*/
select ServiceId, ServiceName, ProviderId, ProviderName   from dbo.ServicesAndProviders with (nolock)

END

-- Parameters for [dbo].[st_GetOtherProductProfitV2] stored

--select * from  Providers
 /*
    2	Bill Payments
    3	Long Distance
    4	Top Ups
    6	Others
    */

    /*
    1	Softgate
    2	TransferTo
    3	Lunex
    4	PureMinutes
    5   Regalii
    6	Others
    */
