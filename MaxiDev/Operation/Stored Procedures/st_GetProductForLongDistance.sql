CREATE PROCEDURE [Operation].[st_GetProductForLongDistance]
	@IdProvider INT
AS
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Gets products for Lunex</Description>

<ChangeLog>
<log Date="29/09/2017" Author="snevarez">S41:Gets products for Lunex</log>
</ChangeLog>
*********************************************************************/
begin try

	SET NOCOUNT ON;

    DECLARE @Products TABLE
    (
	   Id INT IDENTITY(1,1),
	   IdProvider INT,
	   Sku NVARCHAR(150),
	   Product  NVARCHAR(150)
    )

    /*IdProvider:3	ProviderName:Lunex*/
    IF (@IdProvider = 3)
    BEGIN
	
	   INSERT INTO @Products (IdProvider,Sku,Product) VALUES (@IdProvider,'0000','All');

	   /*Get all product of LUNEX*/
	   INSERT INTO @Products (IdProvider,Sku,Product)
		  Select 
			 Distinct 
				IdProvider
				,lp.SKU
				,lp.Product
		  From operation.ProductTransfer AS pt WITH(NOLOCK) 
			 Inner Join lunex.transferln tln ON pt.Idproducttransfer = tln.IdProductTransfer
			 Inner Join lunex.Product AS lp WITH(NOLOCK) ON tln.SKU = lp.SKU
		  Where IdProvider = @IdProvider
			 AND lp.SKU = '1090'; /*Guatemalla*/

	   INSERT INTO @Products (IdProvider,Sku,Product) VALUES (@IdProvider,'0001','Pinless/Long Distance');
		  
    END
    /*IdProvider:4	ProviderName:PureMinutes*/
    --IF (@IdProvider = 4)
    --BEGIN
	   
	   --INSERT INTO @Products (IdProvider,Sku,Product) VALUES (@IdProvider,'0000','All');

	   --INSERT INTO @Products (IdProvider,Sku,Product)
		  --Select 
			 --Distinct 
				--IdProvider
				--,'' AS SKU
				--,'' AS Product
		  --From operation.ProductTransfer AS pt WITH(NOLOCK) 
			 --Inner Join pureminutestransaction pm ON pt.Idproducttransfer=pm.Idproducttransfer
		  --Where IdProvider = @IdProvider;

    --END

    SELECT 
	   Id
	   IdProvider,
	   Sku,
	   Product AS ProductName
    FROM @Products;

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Operation.st_GetProductForLongDistance',Getdate(),@ErrorMessage);
End Catch