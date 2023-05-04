CREATE TABLE [dbo].[Tickets] (
    [IdTicket]                  INT            IDENTITY (1, 1) NOT NULL,
    [TicketDate]                DATETIME       NOT NULL,
    [IdUser]                    INT            NOT NULL,
    [IdProduct]                 INT            NOT NULL,
    [IdTransaction]             INT            NOT NULL,
    [Note]                      NVARCHAR (MAX) NULL,
    [IdStatus]                  INT            NOT NULL,
    [IdPriority]                INT            NOT NULL,
    [IdTicketCloseReason]       INT            NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChange_LastDateChange] DATETIME       NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX) NULL,
    [Reference]                 NVARCHAR (MAX) NOT NULL,
    [OperationDate]             DATETIME       NULL,
    [IdAgent]                   INT            NULL,
    [ClosedDate]                DATETIME       CONSTRAINT [DF_Tickets_ClosedDate] DEFAULT (((1)/(1))/(1900)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdTicket] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [Ticket_SelectedCloseReason] FOREIGN KEY ([IdTicketCloseReason]) REFERENCES [dbo].[TicketCloseReasons] ([IdTicketCloseReason]),
    CONSTRAINT [Ticket_SelectedPriority] FOREIGN KEY ([IdPriority]) REFERENCES [dbo].[TicketPriorities] ([IdTicketPriority]),
    CONSTRAINT [Ticket_SelectedUser] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IX_Tickets_IdTransaction]
    ON [dbo].[Tickets]([IdTransaction] ASC);


GO
CREATE TRIGGER TR_Tickets ON [dbo].[Tickets] AFTER UPDATE 
AS 
/*******************************************************
Creador: Fabian González
Descripcion: Actualiza la fecha de cierre al dia, en caso de que no tenga fecha de cierre.


Fecha de Creacion: 27/02/2017
*****************************************************/

BEGIN 

DECLARE @InsDate DATETIME, @idTicket INT , @IdStatus INT , @OldStatus INT 

	SELECT @OldStatus= IdStatus
	FROM DELETED
	
	SELECT @idTicket=IdTicket , @InsDate = ClosedDate, @IdStatus= IdStatus
	FROM INSERTED

	IF @idStatus = 2 AND @OldStatus != @idStatus AND @InsDate ='19000101' BEGIN 
	  
	  UPDATE Tickets SET ClosedDate =getDate() WHERE IdTicket = @idTicket
	
	END 

END 
