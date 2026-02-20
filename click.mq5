//+------------------------------------------------------------------+
//|                                     QuickRisk_CleanDeinit.mq5    |
//|                                  Copyright 2026, Gemini AI       |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>

//--- INPUT ---
input double InpRiskEUR    = 50.0;       // Rischio fisso in Euro
input double InpRRatio     = 2.0;        // Rapporto R/R (es. 2 = TP doppio dello SL)
input string InpSLName     = "SL_LINE";  // Nome linea Stop Loss
input color  InpLabelColor = clrWhite;   // Colore testo info

//--- GLOBALI ---
CTrade trade;
string labelName = "LBL_INFO";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    CreatePanel();
    CreateLabel();
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Crea Linea SL
    if(ObjectFind(0, InpSLName) < 0) {
        ObjectCreate(0, InpSLName, OBJ_HLINE, 0, 0, currentPrice - (200 * _Point));
        ObjectSetInteger(0, InpSLName, OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, InpSLName, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, InpSLName, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, InpSLName, OBJPROP_BACK, false); 
    }
    
    EventSetTimer(1);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function - PULIZIA TOTALE                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Rimuove i pulsanti (cerca tutti gli oggetti che iniziano con BT_)
    ObjectsDeleteAll(0, "BT_");
    
    // Rimuove l'etichetta info
    ObjectDelete(0, labelName);
    
    // Rimuove specificamente la linea dello Stop Loss
    if(ObjectFind(0, InpSLName) >= 0) {
        ObjectDelete(0, InpSLName);
    }
    
    // Ferma il timer
    EventKillTimer();
    
    Print("EA rimosso: Grafico pulito con successo.");
}

//+------------------------------------------------------------------+
//| ChartEvents                                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if(id == CHARTEVENT_OBJECT_DRAG && sparam == InpSLName) UpdateLiveInfo();
    
    if(id == CHARTEVENT_OBJECT_CLICK) {
        if(sparam == "BT_BUY")  ExecuteTrade(ORDER_TYPE_BUY);
        if(sparam == "BT_SELL") ExecuteTrade(ORDER_TYPE_SELL);
        ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
    }
}

void OnTimer() { UpdateLiveInfo(); }

//+------------------------------------------------------------------+
//| Logica di Calcolo                                                |
//+------------------------------------------------------------------+
void UpdateLiveInfo() {
    double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = ObjectGetDouble(0, InpSLName, OBJPROP_PRICE);
    double lots = CalculateLots(price, sl);
    double pips = MathAbs(price - sl) / _Point;
    
    string info = StringFormat("RISCHIO: %.2f EUR | SL: %.1f Punti | LOTTI: %.2f | TP 1:%.0f", 
                               InpRiskEUR, pips, lots, InpRRatio);
    ObjectSetString(0, labelName, OBJPROP_TEXT, info);
}

double CalculateLots(double price, double sl) {
    double diff = MathAbs(price - sl);
    if(diff <= 0) return 0.01;

    double tickVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    double lotSize = InpRiskEUR / (diff * (tickVal / tickSize));
    
    double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    lotSize = MathFloor(lotSize / step) * step;
    
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    return (lotSize < minLot) ? minLot : lotSize;
}

void ExecuteTrade(ENUM_ORDER_TYPE type) {
    double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = ObjectGetDouble(0, InpSLName, OBJPROP_PRICE);
    double dist = MathAbs(price - sl);
    
    double tp = (type == ORDER_TYPE_BUY) ? price + (dist * InpRRatio) : price - (dist * InpRRatio);
    double lots = CalculateLots(price, sl);

    trade.SetExpertMagicNumber(112233);
    trade.PositionOpen(_Symbol, type, lots, price, sl, tp, "QuickRisk_1-2");
}

//+------------------------------------------------------------------+
//| UI Helpers                                                       |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, color bg) {
    ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, 80);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, 30);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
}

void CreatePanel() {
    CreateButton("BT_BUY", "BUY", 20, 30, clrGreen);
    CreateButton("BT_SELL", "SELL", 110, 30, clrRed);
}

void CreateLabel() {
    ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 70);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, InpLabelColor);
}