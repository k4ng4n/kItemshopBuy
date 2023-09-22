--[[
  ItemShopMultiBuy Addon
  Author: Kangan
  What is it for: With this addon you can buy up to 999 items at once from the itemshop
]]

local me = {
  name = "kItemshopBuy",
  vars = {
    elapsed = 0,
    buySpeed = (GetPing()/1000)+0.05,
    buyActive = false,
    amount = 0,
  },
  func = {},
}

function me.func.OnUpdate(_elapsed)
  me.vars.elapsed = me.vars.elapsed + _elapsed
  if (me.vars.elapsed < me.vars.buySpeed) then return; end

  if (me.vars.buyActive) then
    me.vars.elapsed = 0
    me.func.updateSpeed()
    me.func.buyAmount()
  end
end

function me.func.updateSpeed()
  if ((GetPing()/1000)+0.05 ~= me.vars.buySpeed) then
    me.vars.buySpeed = (GetPing()/1000)+0.05
  end
end

function me.func.buyAmount()
  -- amount == 0 abfangen
  if (me.vars.amount == 0) then 
    me.vars.buyActive = false -- buy stop
		return;
  end
  -- checks sec password
  if (not CheckPasswordState()) then
    me.vars.buyActive = false -- buy stop
		return;
	end
  -- wenn Itemshop geschlossen wird dann auch kauf abbrechen
  if (not ItemMallFrame:IsVisible() or not IM2_BuyFrame:IsVisible()) then
    me.vars.buyActive = false -- buy stop
		return;
  end
  -- check free bag slots
  if (not me.func.freeItemShopBagSlots()) then
    me.vars.buyActive = false -- buy stop
		return;
  end

  -- get variables
	local count = me.vars.amount;
	local dias = GetPlayerMoney("account"); --dias
	local rubies = GetPlayerMoney("bonus"); --rubis
	local ptk = GetPlayerMoney("billdin"); -- phirius marken
	local item = ItemMallFrame.selectItem;

	if ((dias >= item.accountMoney * count) and -- Spieler hat mehr dias als gesamtPreis
		(rubies >= item.bonusMoney * count ) and -- Spieler hat mehr rubis als gesamtPreis
		(ptk>=item.freeMoney * count )) -- Spieler hat mehr ph-marken als gesamtPreis
  then -- starte kauf
    CIMF_ShoppingBuy(item.GUID, 1);
    me.vars.amount = me.vars.amount - 1
    IM2_Amountoverride:SetNumber(me.vars.amount)
  else -- gib Meldung aus
		local str="";

		if (dias < item.accountMoney * count) then
      str=string.format("Not enough Diamonds: You have %d of %d", dias, item.accountMoney * count);
      SendSystemChat(str)
      SendWarningMsg(str)
		end
		if (rubies < item.bonusMoney * count) then
      str=string.format("Not enough Rubies: You have %d of %d", rubies, item.bonusMoney * count);
      SendSystemChat(str)
      SendWarningMsg(str)
		end
		if (ptk <item.freeMoney * count) then
      str=string.format("Not enough Phirius Token Coins: You have %d of %d", ptk, item.freeMoney * count);
      SendSystemChat(str)
      SendWarningMsg(str)
		end

    me.vars.buyActive = false -- stop
	end
end

function me.func.freeItemShopBagSlots()
  for i = 1, 50 do
    local inventoryIndex, icon, name, itemCount, locked, quality = GetBagItemInfo(i)
    if (not (name and name ~= "")) then
      return true
    end
  end
  return false
end

function me.func.updateCosts()
  local count = me.vars.amount
  local item = ItemMallFrame.selectItem;
  IM2_Amountoverride_Diaicon:Hide()
  IM2_Amountoverride_Rubyicon:Hide()
  IM2_Amountoverride_Ptkicon:Hide()
  IM2_Amountoverride_Dias:Hide()
  IM2_Amountoverride_Rubies:Hide()
  IM2_Amountoverride_Ptk:Hide()

  if (item.accountMoney > 0) then
    IM2_Amountoverride_Diaicon:Show()
    IM2_Amountoverride_Dias:Show()
    IM2_Amountoverride_Dias:SetText(item.accountMoney * count)
    IM2_Amountoverride_Dias:SetColor(0,0.5,1)
  end
  if (item.bonusMoney > 0) then
    IM2_Amountoverride_Rubyicon:Show()
    IM2_Amountoverride_Rubies:Show()
    IM2_Amountoverride_Rubies:SetText(item.bonusMoney * count)
    IM2_Amountoverride_Rubies:SetColor(1,0,0)
  end
  if (item.freeMoney > 0) then
    IM2_Amountoverride_Ptkicon:Show()
    IM2_Amountoverride_Ptk:Show()
    IM2_Amountoverride_Ptk:SetText(item.freeMoney * count)
  end
end

function me.func.resetUI()
  me.vars.buyActive = false
  me.vars.amount = 0
  IM2_Amountoverride:SetNumber(0)
  IM2_Amountoverride_Dias:SetText("0")
  IM2_Amountoverride_Dias:SetColor(1,1,1)
  IM2_Amountoverride_Rubies:SetText("0")
  IM2_Amountoverride_Rubies:SetColor(1,1,1)
  IM2_Amountoverride_Ptk:SetText("0")
end

_G[me.name] = me