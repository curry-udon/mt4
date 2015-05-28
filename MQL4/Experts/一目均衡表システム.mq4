// マジックナンバーの定義
#define MAGIC 1234

// パラメーターの設定//
extern int Tenkan = 6; // 転換線の期間設定
extern int Kijun = 26; // 基準線の期間設定
extern int Senkou = 52; // 先行線の期間設定

extern double Lots = 1.0; // 取引ロット数
extern int Slip = 10; // 許容スリッページ数
extern string Comments = " "; // コメント

// 変数の設定//
int Ticket_L = 0; // 買い注文の結果をキャッチする変数
int Ticket_S = 0; // 売り注文の結果をキャッチする変数
int Exit_L = 0; // 買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0; // 売りポジションの決済注文の結果をキャッチする変数

double SenkouA_2 = 0; /*2 本前のバーの先行スパンA に変身したiCustom
　　　　　　　　　　　　　関数を代入する変数*/
double SenkouB_2 = 0; /*2 本前のバーの先行スパンB に変身したiCustom
　　　　　　　　　　　　　関数を代入する変数*/
double SenkouA_1 = 0; /*1 本前のバーの先行スパンA に変身したiCustom
　　　　　　　　　　　　　関数を代入する変数*/
double SenkouB_1 = 0; /*1 本前のバーの先行スパンB に変身したiCustom
　　　　　　　　　　　　　関数を代入する変数*/


int start()
{

   SenkouA_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,2);
   SenkouB_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,2);
   SenkouA_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,1);
   SenkouB_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,1);

   // 買いポジションのエグジット
   if( ( SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2] )
      && SenkouA_1 > Close[1] && SenkouB_1 > Close[1]
      && ( Ticket_L != 0 && Ticket_L != -1 ))
      {
         Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
         if( Exit_L == 1 ) {Ticket_L = 0;}
      }
      
   // 売りポジションのエグジット
   if( ( SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2] )
      && SenkouA_1 < Close[1] && SenkouB_1 < Close[1]
      && ( Ticket_S != 0 && Ticket_S != -1 ))
      {
         Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
         if( Exit_S == 1 ) {Ticket_S = 0;}
      }
      
   // 買いエントリー
   if( ( SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2] )
      && SenkouA_1 < Close[1] && SenkouB_1 < Close[1]
      && ( Ticket_L == 0 || Ticket_L == -1 )
      && ( Ticket_S == 0 || Ticket_S == -1 ))
      {
         Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if( ( SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2] )
      && SenkouA_1 > Close[1] && SenkouB_1 > Close[1]
      && ( Ticket_S == 0 || Ticket_S == -1 )
      && ( Ticket_L == 0 || Ticket_L == -1 ))
      {
         Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
   
return(0);
}