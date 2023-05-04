CREATE TABLE [dbo].[GatewayDataTmp] (
    [IdGatewayDataTmp] INT            IDENTITY (1, 1) NOT NULL,
    [IdGateway]        INT            NULL,
    [Claimcode]        NVARCHAR (MAX) NULL,
    [Returncode]       NVARCHAR (MAX) NULL,
    [Returncodetype]   INT            NULL,
    [XMLValue]         XML            NULL
);

