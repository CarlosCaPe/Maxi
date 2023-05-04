CREATE function [dbo].[fn_GetOtherProductTypeOfMovement](@IdOtherProduct int, @IsDebit int) 
returns nvarchar(max)
as
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin    
    declare @TypeOfMovement nvarchar(max)

    select 
        @TypeOfMovement=typeofmovement 
    from 
        otherproducts o with(nolock)
    join 
        agentbalancehelper h with(nolock) on o.IdOtherProducts=h.IdOtherProduct
    where 
        o.IdOtherProducts=@IdOtherProduct 
        and h.isdebit=@IsDebit

return @TypeOfMovement

end
