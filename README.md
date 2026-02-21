# 📊 QuickRisk for MetaTrader 5

**QuickRisk** is a streamlined risk management Expert Advisor (EA) designed for MT5. It allows traders to visually define their risk directly on the chart using a draggable Stop Loss line, providing real-time lot size calculations based on a fixed Euro amount.

---

## ✨ Key Features

* **Visual Risk Calculation:** Drag the `SL_LINE` on your chart to see instant updates on Lot Size and Pip distance.
* **Fixed Cash Risk:** Risk a specific amount of money (e.g., €50.00) regardless of the Stop Loss distance.
* **Dynamic R/R Ratio:** Automatically sets your Take Profit based on your preferred Reward-to-Risk ratio (default 1:2).
* **One-Click Execution:** Integrated "BUY" and "SELL" buttons for rapid market entry.
* **Total Cleanup:** Unlike many EAs, this script automatically removes all buttons, labels, and lines from your chart when it is unattached.

---

## 🛠️ Installation

1.  Open your **MetaTrader 5** terminal.
2.  Navigate to `File` > `Open Data Folder`.
3.  Go to `MQL5` > `Experts`.
4.  Copy the `QuickRisk_CleanDeinit.mq5` file into this folder.
5.  In MT5, right-click **Expert Advisors** in the Navigator window and select **Refresh**.
6.  Drag the EA onto any chart and ensure **"Allow Algo Trading"** is enabled in the common tab.

---

## ⚙️ Input Parameters

| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| `InpRiskEUR` | `50.0` | Total money (EUR) to risk per trade. |
| `InpRRatio` | `2.0` | Reward-to-Risk ratio (e.g., 2.0 = TP is 2x SL distance). |
| `InpSLName` | `SL_LINE` | The name of the horizontal line used for SL calculation. |
| `InpLabelColor`| `clrWhite` | Color of the information text displayed on the chart. |

---

## 🚀 How to Use

1.  **Position the Line:** Move the red horizontal line (`SL_LINE`) to your desired Stop Loss level.
2.  **Check the Dashboard:** The text on the chart updates every second (or upon dragging) to show your calculated **LOTS**.
3.  **Execute Trade:** * Click **BUY**: Opens a position with SL at the line and TP at the 1:2 ratio.
    * Click **SELL**: Opens a position with SL at the line and TP at the 1:2 ratio.
4.  **Exit:** Simply remove the EA from the chart. The code triggers a "Clean Deinit," removing all graphical objects it created.

---

## 📝 Technical Logic

The lot size is calculated using the following formula:

$$LotSize = \frac{RiskAmount}{Distance \times (\frac{TickValue}{TickSize})}$$

The EA also accounts for `SYMBOL_VOLUME_STEP` and `SYMBOL_VOLUME_MIN` to ensure the order is compatible with your broker's requirements.

---

## ⚠️ Disclaimer

*This software is for educational purposes only. Trading Forex, Stocks, and CFDs involves significant risk. Past performance is not indicative of future results. Always test on a Demo Account before using real capital.*

---
**Author:** Gemini AI  
**Year:** 2026
