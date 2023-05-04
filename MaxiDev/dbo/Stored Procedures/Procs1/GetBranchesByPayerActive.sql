/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>Activiar campo de telefono beneficiario por pagador</Description>

<ChangeLog>
    <log Date="31/07/2020" Author="jgomez">Activiar campo de telefono beneficiario por pagado</log>
    <log Date="08/04/2022" Author="jcsierra"> Add BenCellPhoneRequiredPrefix column  </log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [dbo].[GetBranchesByPayerActive](
    @IdPayer        INT
)
AS
BEGIN
    SELECT 
        BenCellPhoneIsRequired, 
        BenCellPhoneRequiredPrefix 
    FROM PayerConfig pc WITH(NOLOCK) 
    WHERE 
        pc.IdPayer = @IdPayer 
        AND pc.IdPaymentType = 6
END
