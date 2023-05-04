CREATE TABLE [dbo].[DashboardForGatewayCountry] (
    [IdDashboard]     INT          IDENTITY (1, 1) NOT NULL,
    [IdAgent]         INT          NULL,
    [IdGateway]       INT          NULL,
    [IdPayer]         INT          NULL,
    [IdCountry]       INT          NULL,
    [AgentState]      NVARCHAR (5) NULL,
    [NumTran]         INT          NULL,
    [AmountInDollars] MONEY        NULL,
    [Date]            DATETIME     NULL,
    CONSTRAINT [PK_DashboardForGatewayCountry] PRIMARY KEY CLUSTERED ([IdDashboard] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_DashboardForGatewayCountry_Date]
    ON [dbo].[DashboardForGatewayCountry]([Date] ASC)
    INCLUDE([IdAgent], [IdGateway], [IdPayer], [IdCountry], [NumTran], [AmountInDollars]);


GO
CREATE NONCLUSTERED INDEX [IX_DashboardForGatewayCountry_IdAgent_Date]
    ON [dbo].[DashboardForGatewayCountry]([IdAgent] ASC, [Date] ASC)
    INCLUDE([IdGateway], [IdPayer], [IdCountry], [NumTran], [AmountInDollars]);

