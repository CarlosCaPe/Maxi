
CREATE PROCEDURE [dbo].[st_GetLastTransfersByCustomer]--1206529, 1
  @IdCustomer INT,
  @IsModify   BIT = 0
/********************************************************************
<Author>???</Author>
<app>Agent</app>
<Description>Obtiene la infomacion de la ultima transaccion</Description>

<ChangeLog>
<log Date="" Author="">Fix:0000737: Borrar datos de información de envío</log>
<log Date="" Author="">MA_008: Se añade el tipo de pago ATM</log>
<log Date="" Author="">Se agrega IdCountry Ref:: M00022-Busqueda_Ciudades</log>
<log Date="" Author="">se cambio JOIN por LEFT JOIN para mostrar beneficiarios sin transferencia</log>
<log Date="" Author="">CR - M00254 - MEJORA EN CARGA DE LOCACIONES</log>
<log Date="" Author="">Se agrega funcionalidad para obtener beneficiarios desde la pantalla de mon}dificaion de remesa</log>
<log Date="" Author="">Se agrega la columna IdDialingCodeBeneficiaryPhoneNumber al resultado</log>
<log Date="03/11/2022" Author="maprado">MP-1084 Se agrega logica para obtener bandera de numero requerido de las ultimas 4 transacciones</log>
</ChangeLog>
*********************************************************************/
AS
BEGIN try
	DECLARE @tTransfersByBeneficiary TABLE (
		idtransfer    INT,
		idbeneficiary INT);

	/*MP-1084 - Begin*/
	DECLARE @tTransfersWithFlagRequiredCustomerPhone TABLE (
		IdTransfer						INT,
		IsRequiredCustomerPhoneNumber	BIT);

	DECLARE @TotalTransfersWithFlag INT;
	/*MP-1084 - End*/

	DECLARE @IdPaymentTypeDirectCash INT
	SET @IdPaymentTypeDirectCash =4;

	DECLARE @IdPaymentTypeCash INT
	SET @IdPaymentTypeCash =1;

	DECLARE @IdGenericStatusEnabled INT
	SET @IdGenericStatusEnabled =1;

	/*Fix:0000737 - Begin*/
	DECLARE @IdPaymentTypeDeposit INT
	SET @IdPaymentTypeDeposit = 2;

	DECLARE @IdPaymentTypeMobileWallet INT
	SET @IdPaymentTypeMobileWallet = 5;
	/*Fix:0000737 - End*/

	/*MA_008 - Begin*/
	DECLARE @IdPaymentTypeAtm INT
	SET @IdPaymentTypeAtm = 6;
    /*MA_008 - End*/

	/*MP-1084 - Begin*/
	INSERT INTO @tTransfersWithFlagRequiredCustomerPhone(IdTransfer,IsRequiredCustomerPhoneNumber)
    SELECT TOP(4) TF.IdTransfer, TF.IsRequiredCustomerPhoneNumber
    FROM (
		SELECT T.IdTransfer,T.IsRequiredCustomerPhoneNumber
        FROM dbo.transfer T WITH (NOLOCK)
        WHERE  T.IdCustomer = @IdCustomer 
		UNION
		SELECT T.IdTransferClosed,T.IsRequiredCustomerPhoneNumber
		FROM dbo.transferclosed T WITH (NOLOCK)
		WHERE  T.IdCustomer = @IdCustomer
	)TF
    ORDER BY TF.IdTransfer DESC;

	SELECT @TotalTransfersWithFlag = COUNT(*)
	FROM @tTransfersWithFlagRequiredCustomerPhone TF
	WHERE ISNULL(TF.IsRequiredCustomerPhoneNumber,0) = 1;

    /*MP-1084 - End*/

      IF ( @IsModify = 1 )
        BEGIN
            INSERT INTO @tTransfersByBeneficiary
                        (idtransfer,
                         idbeneficiary)
            SELECT TOP 1000 ( LF.idtransfer ) IdTransfer,
                            LF.idbeneficiary
            FROM   (SELECT T.idtransfer,
                           T.idbeneficiary
                    FROM   dbo.transfer T WITH (nolock)
                    --inner join dbo.Payer P on P.IdPayer =T.IdPayer  
                    --left join dbo.Branch B on B.IdBranch = T.IdBranch  
                    WHERE  T.idcustomer = @IdCustomer
                    --and P.IdGenericStatus=1 and (B.IdGenericStatus is null or B.IdGenericStatus=1)  
                    UNION
                    SELECT T.idtransferclosed,
                           T.idbeneficiary
                    FROM   dbo.transferclosed T WITH (nolock)
                    --inner join dbo.Payer P on P.IdPayer =T.IdPayer  
                    --left join dbo.Branch B on B.IdBranch = T.IdBranch  
                    WHERE  T.idcustomer = @IdCustomer
                   --and P.IdGenericStatus=1 and (B.IdGenericStatus is null or B.IdGenericStatus=1)    
                   )LF
            ORDER  BY idtransfer DESC
        END
      ELSE
        BEGIN
            INSERT INTO @tTransfersByBeneficiary
                        (idtransfer,
                         idbeneficiary)
            SELECT Max(LF.idtransfer) IdTransfer,
                   LF.idbeneficiary
            FROM   (SELECT T.idtransfer,
                           T.idbeneficiary
                    FROM   dbo.transfer T WITH (nolock)
                    --inner join dbo.Payer P on P.IdPayer =T.IdPayer  
                    --left join dbo.Branch B on B.IdBranch = T.IdBranch  
                    WHERE  T.idcustomer = @IdCustomer
                    --and P.IdGenericStatus=1 and (B.IdGenericStatus is null or B.IdGenericStatus=1)  
                    UNION
                    SELECT T.idtransferclosed,
                           T.idbeneficiary
                    FROM   dbo.transferclosed T WITH (nolock)
                    --inner join dbo.Payer P on P.IdPayer =T.IdPayer  
                    --left join dbo.Branch B on B.IdBranch = T.IdBranch  
                    WHERE  T.idcustomer = @IdCustomer
                   --and P.IdGenericStatus=1 and (B.IdGenericStatus is null or B.IdGenericStatus=1)    
                   )LF
            GROUP  BY LF.idbeneficiary
        END

      SELECT LT.[idtransfer],
             LT.[idcustomer],
             CASE
               WHEN LT.[idtransfer] IS NULL THEN -1
               WHEN LT.idpaymenttype = @IdPaymentTypeDirectCash THEN
               @IdPaymentTypeCash
               ELSE LT.[idpaymenttype]
             END IdPaymentType,
             LT.[idbranch],
             Isnull(psc.idpayersurrogate, LT.[idpayer]) IdPayer,
             LT.[idgateway],
             LT.[gatewaybranchcode],
             LT.[idagentpaymentschema],
             LT.[idagent],
             LT.[idagentschema],
             LT.[idcountrycurrency],
             LT.[idcountry] --M00022-Busqueda_Ciudades
             ,
             LT.[idstatus],
             LT.[claimcode],
             LT.[confirmationcode],
             LT.[amountindollars],
             LT.[fee],
             LT.[agentcommission],
             LT.[corporatecommission],
             LT.[dateoftransfer],
             LT.[exrate],
             LT.[referenceexrate],
             LT.[amountinmn],
             LT.[folio],
             LT.[depositaccountnumber],
             LT.[totalamounttocorporate]
             --,LT.IdCity  
             ,
             CASE
               WHEN LT.idpaymenttype IN ( @IdPaymentTypeDeposit,
                                          @IdPaymentTypeMobileWallet,
                                                 @IdPaymentTypeAtm )
                    AND LT.idcity IS NULL THEN
             /*ISNULL((
             SELECT TOP 1 IdCity FROM Payer AS P WITH(NOLOCK) INNER JOIN Branch B ON B.IdPayer = P.IdPayer 
             WHERE P.IdPayer = LT.IdPayer
             ),[TransferIdCity]),*/
             Iif(branchcodeisrequired = 1, Isnull(
             (SELECT TOP 1 idcity
              FROM   payer AS P WITH(nolock
                     )
                     INNER JOIN branch B
                             ON B.idpayer =
                                P.idpayer
              WHERE  P.idpayer = LT.idpayer),
                                           [transferidcity]), [transferidcity])
               ELSE LT.idcity
             END IdCity /*Fix:0000737*/
             --,LT.IdState  
             ,
             CASE
               WHEN LT.idpaymenttype IN ( @IdPaymentTypeDeposit,
                                          @IdPaymentTypeMobileWallet,
                                                 @IdPaymentTypeAtm )
                    AND LT.idcity IS NULL THEN Isnull((SELECT TOP 1 S.idstate
                                                       FROM   payer AS P WITH(
                                                              nolock)
                                                              INNER JOIN
                                                              branch AS B
                                                              WITH(
                                                              nolock)
                                                                      ON
                                                              P.idpayer =
                                                              B.idpayer
                                               INNER JOIN
                                               city AS C WITH(
                                               nolock)
                                                       ON B.idcity
                                               =
                                                          C.idcity
                                               INNER JOIN state AS
                                               S
                                                          WITH(
                                                          nolock)
                                                       ON
                                               C.idstate =
                                               S.idstate
                                                       WHERE
                                               P.idpayer = LT.idpayer
                                               ), LT.idstate)
               ELSE LT.idstate
             END IdState /*Fix:0000737*/
             ,
             LT.idonwhosebehalf,
             Isnull(LT.purpose, '')                     Purpose,
             Isnull(LT.relationship, '')                Relationship,
             Isnull(LT.moneysource, '')                 MoneySource,
             B.[idbeneficiary],
             B.[name],
             B.[firstlastname],
             B.[secondlastname],
             B.[address],
             B.[city],
             B.[state],
             B.[country],
             B.[zipcode],
             B.[phonenumber],
             B.[celullarnumber],
             B.[ssnumber],
             B.[borndate],
             B.[occupation],
             B.[note],
             B.[idgenericstatus],
             B.idbeneficiaryidentificationtype,
             B.identificationnumber
             BeneficiaryIdentificationNumber,
             B.idcountryofbirth                         IdCountryOfBirth,
             LT.[accounttypeid],
             CASE
               WHEN LT.branchcodepontual IS NULL THEN ''
               ELSE LT.branchcodepontual
             END BranchCodePontual,
             --CR - M00259 LT.BranchCodePontual, --CR - M00259
             CASE
               WHEN LT.branchcodeisrequired IS NULL THEN Cast(0 AS BIT)
               ELSE LT.branchcodeisrequired
             END BranchCodeIsRequired,
             --CR - M00259
             LT.iddialingcodebeneficiaryphonenumber,
			 CASE
               WHEN @TotalTransfersWithFlag > 0 THEN Cast(0 AS BIT)
               ELSE Cast(1 AS BIT)
             END FlagRequiredCustomerPhone
      FROM   (SELECT idtransfer,
                     idbeneficiary
              FROM   @tTransfersByBeneficiary
              UNION
              SELECT NULL IdTransfer,
                     B.idbeneficiary
              FROM   beneficiary B WITH (nolock)
              WHERE  idcustomer = @IdCustomer
              AND idbeneficiary NOT IN(SELECT idbeneficiary FROM   @tTransfersByBeneficiary))L
			  INNER JOIN dbo.beneficiary B WITH (NOLOCK) ON B.idbeneficiary = L.idbeneficiary AND B.idgenericstatus = @IdGenericStatusEnabled
			  LEFT JOIN (SELECT idtransferclosed [IdTransfer],
                               TC.[idcustomer]
                               --,TC.[IdBeneficiary]  
                               ,[idpaymenttype],
                               TC.[idbranch],
                               TC.[idpayer],
                               [idgateway],
                               [gatewaybranchcode],
                               [idagentpaymentschema],
                               [idagent],
                               [idagentschema],
                               TC.[idcountrycurrency] --M00022-Busqueda_Ciudades
                               ,[idstatus],
                               [claimcode],
                               [confirmationcode],
                               [amountindollars],
                               [fee],
                               [agentcommission],
                               [corporatecommission],
                               [dateoftransfer],
                               [exrate],
                               [referenceexrate],
                               [amountinmn],
                               [folio],
                               [depositaccountnumber],
                               TC.[dateoflastchange],
                               TC.[enterbyiduser],
                               [totalamounttocorporate],
                               Br.idcity,
                               C.idstate,
                               TC.idonwhosebehalf,
                               TC.purpose,
                               TC.relationship,
                               TC.moneysource,
                               [accounttypeid],
                               TC.[transferidcity] /*Fix:0000737*/
                               ,CO.idcountry --M00022-Busqueda_Ciudades
                               ,'' AS BranchCodePontual
                               --CR - M00259
                               ,Cast (0 AS BIT) AS BranchCodeIsRequired,
                               --CR - M00259]
                               TC.iddialingcodebeneficiaryphonenumber
                        FROM   [dbo].transferclosed TC WITH (NOLOCK)
                               LEFT JOIN dbo.branch Br WITH (NOLOCK) ON Br.idbranch = TC.idbranch
                               LEFT JOIN dbo.city C WITH (NOLOCK) ON C.idcity = Br.idcity
                               LEFT JOIN dbo.countrycurrency CC WITH (NOLOCK) ON CC.idcountrycurrency = TC.idcountrycurrency
                               --M00022-Busqueda_Ciudades
                               LEFT JOIN dbo.country CO WITH (NOLOCK) ON CC.idcountry = CO.idcountry
                        --M00022-Busqueda_Ciudades
                        UNION
                        SELECT [idtransfer],
                               T.[idcustomer]
                               --,T.[IdBeneficiary]  
                               ,T.[idpaymenttype],
                               T.[idbranch],
                               T.[idpayer],
                               T.[idgateway],
                               [gatewaybranchcode],
                               [idagentpaymentschema],
                               [idagent],
                               [idagentschema],
                               T.[idcountrycurrency],
                               [idstatus],
                               [claimcode],
                               [confirmationcode],
                               [amountindollars],
                               [fee],
                               [agentcommission],
                               [corporatecommission],
                               [dateoftransfer],
                               [exrate],
                               [referenceexrate],
                               [amountinmn],
                               [folio],
                               [depositaccountnumber],
                               T.[dateoflastchange],
                               T.[enterbyiduser],
                               [totalamounttocorporate],
                               Br.idcity,
                               C.idstate,
                               T.idonwhosebehalf,
                               T.purpose,
                               T.relationship,
                               T.moneysource,
                               [accounttypeid],
                               T.[transferidcity] /*Fix:0000737*/
                               ,CO.idcountry --M00022-Busqueda_Ciudades
                               ,CASE
                                 WHEN PC.branchcodeisrequired = 1
                                      AND PC.idpayer = T.idpayer
                                      AND T.idpaymenttype = 2
                                      AND T.idcountrycurrency = 3 THEN
                                 T.branchcodepontual
                                 ELSE ''
                               END BranchCodePontual --CR - M00259
                               ,CASE
                                 WHEN PC.branchcodeisrequired = 1
                                      AND PC.idpayer = T.idpayer
                                      AND T.idpaymenttype = 2
                                      AND T.idcountrycurrency = 3 THEN
                                 PC.branchcodeisrequired
                                 ELSE Cast (0 AS BIT)
                               END BranchCodeIsRequired,--CR - M00259
                               T.iddialingcodebeneficiaryphonenumber
                        FROM   [dbo].[transfer] T WITH (NOLOCK)
                               LEFT JOIN dbo.branch Br WITH (NOLOCK) ON Br.idbranch = T.idbranch
                               LEFT JOIN dbo.city C WITH (NOLOCK) ON C.idcity = Br.idcity
                               LEFT JOIN dbo.countrycurrency CC WITH(nolock) ON CC.idcountrycurrency = T.idcountrycurrency
                               --M00022-Busqueda_Ciudades
                               LEFT JOIN dbo.country CO WITH (NOLOCK) ON CC.idcountry = CO.idcountry
                               --M00022-Busqueda_Ciudades
                               LEFT JOIN dbo.payerconfig PC WITH (NOLOCK) ON PC.idpayer = T.idpayer) LT
                    ON L.idtransfer = LT.idtransfer
             LEFT JOIN payer p WITH (NOLOCK) ON p.idpayer = LT.idpayer
             LEFT JOIN payersurrogateconfig psc WITH (NOLOCK) ON psc.idpayer = p.idpayer AND p.idgenericstatus = 2
  END try

  BEGIN catch
      INSERT INTO errorlogforstoreprocedure
                  (storeprocedure,
                   errordate,
                   errormessage)
      VALUES     ('[dbo].[st_GetLastTransfersByCustomer]',
                  Getdate(),
                  Error_message())
  END catch 