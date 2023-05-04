CREATE PROCEDURE [Corp].[st_PayersSendToMexicoAndDontSendDollars](
   @IdCountryCurrency INT = NULL
)
as  

   DECLARE @IdCountryCurrencyMexicoPesos VARCHAR(50) = CAST( dbo.GetGlobalAttributeByName('IdCountryCurrencyMexicoPesos')  as int) 
      ,@IsEnabled INT = 1/*enabled*/
   --------------------------------

   declare @salida table
   (
        IdPayer	int,
        PayerName	nvarchar(max),
        PayerCode	nvarchar(max),
        refexrate money,
        spread money
   )

   IF ISNULL(@IdCountryCurrency,0) <= 0
   BEGIN
      insert into @salida
      SELECT P.IdPayer,  
        P.PayerName,  
        P.PayerCode,
        --dbo.FunRefExRate(PC.IdCountryCurrency,pc.idgateway,p.IdPayer) refexrate        
        (ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0)))) refexrate,
        dbo.[FunSpreadByCountryCurrencyGatewayPayer](pc.IdCountryCurrency,pc.idgateway,pc.idpayer,1) spread
      FROM Payer P WITH(NOLOCK)
       INNER JOIN   
        (   
         SELECT DISTINCT PC.IdPayer,pc.idgateway,PC.IdCountryCurrency 
         FROM PayerConfig PC WITH(NOLOCK)
         WHERE PC.IdCountryCurrency = @IdCountryCurrencyMexicoPesos
           and PC.IdGenericStatus = @IsEnabled  
        )PC ON PC.IdPayer =P.IdPayer  
        LEFT JOIN RefExRate R1 WITH(NOLOCK) ON R1.IdCountryCurrency=PC.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and pc.IdGateway=R1.IdGateway and p.IdPayer=R1.IdPayer  
        LEFT JOIN RefExRate R2 WITH(NOLOCK) ON R2.IdCountryCurrency=PC.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and pc.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
        LEFT JOIN RefExRate R3 WITH(NOLOCK) ON R3.IdCountryCurrency=PC.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
      WHERE P.IdGenericStatus = @IsEnabled
   END
   ELSE
   BEGIN
      insert into @salida
      SELECT P.IdPayer,  
        P.PayerName,  
        P.PayerCode,
        --dbo.FunRefExRate(PC.IdCountryCurrency,pc.idgateway,p.IdPayer) refexrate        
        (ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0)))) refexrate,
        dbo.[FunSpreadByCountryCurrencyGatewayPayer](pc.IdCountryCurrency,pc.idgateway,pc.idpayer,1) spread  
      FROM Payer P WITH(NOLOCK)
       INNER JOIN   
        (   
         SELECT DISTINCT PC.IdPayer,pc.idgateway,PC.IdCountryCurrency 
         FROM PayerConfig PC WITH(NOLOCK)
         WHERE PC.IdCountryCurrency =   @IdCountryCurrency
           and PC.IdGenericStatus = @IsEnabled  
        )PC ON PC.IdPayer =P.IdPayer  
        LEFT JOIN RefExRate R1 WITH(NOLOCK) ON R1.IdCountryCurrency=PC.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and pc.IdGateway=R1.IdGateway and p.IdPayer=R1.IdPayer  
        LEFT JOIN RefExRate R2 WITH(NOLOCK) ON R2.IdCountryCurrency=PC.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and pc.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
        LEFT JOIN RefExRate R3 WITH(NOLOCK) ON R3.IdCountryCurrency=PC.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
      WHERE P.IdGenericStatus = @IsEnabled
   END

   select IdPayer,PayerName+' ('+convert(varchar,refexrate+spread)+')' PayerName,PayerCode from @salida order by refexrate+spread desc,payername
