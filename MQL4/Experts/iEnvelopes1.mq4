
// �}�W�b�N�i���o�[�̒�`
#define MAGIC 3986

// �p�����[�^�[�̐ݒ�//
extern int MA_Period=24;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int Applied_Price=0;
extern double Deviation1=0.5;
extern double Deviation2=0.75;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Envelope1";
extern int TP = 50;
extern int LC = 1500;

// �ϐ��̐ݒ�//
int TicketL = 0; // ���������̌��ʂ��L���b�`����ϐ�
int TicketS = 0; // ���蒍���̌��ʂ��L���b�`����ϐ�
int ExitL = 0; // �����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�
int ExitS = 0; // ����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�


double OuterP2 = 0;
double OuterM2 = 0;
double InnerP2 = 0;
double InnerM2 = 0;
double OuterP1 = 0;
double OuterM1 = 0;
double InnerP1 = 0;
double InnerM1 = 0;
double MA2 =0;
double MA1 =0;

//�V�����o�[�̊J�n���ɏ������s��
	extern bool OpenPriceOnly = false;
	int previousBar = -1;

//----new function---------------
int BUYpos,SELLpos;
void PosCheck(int magic){
    int buypos=0,sellpos=0;
    for(int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i, SELECT_BY_POS) == false) break;
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(OrderType() == OP_BUY )buypos++;
            if(OrderType() == OP_SELL)sellpos++;
        }              
    }
    BUYpos = buypos;
    SELLpos = sellpos;
    return(false);   
}
void  ClosedAll(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY)  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if (OrderType() == OP_SELL) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}


/*
//�|�W�V�����̃e�C�N�v���t�B�b�g
void  ClosedTP(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() + TP * Point <= Bid))  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() - TP * Point >= Ask)) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}
*/
//�|�W�V�����̃��X�J�b�g
void  ClosedLC(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() - LC * Point >= Bid))  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() + LC * Point <= Ask)) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}
//---added-----------------------


int start()
{

//---added-----------------------
   /*
	//�|�W�V�����̃e�C�N�v���t�B�b�g����
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedTP(MAGIC);  
   */
   
	//�|�W�V�����̃��X�J�b�g����
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedLC(MAGIC);  
   
//---added----------------------- 

	//�V�����o�[�̊J�n���ɏ������s��
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;



 OuterP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,2);//-0.75
 OuterM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,2);//-0.75
 InnerP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,2);//-0.5
 InnerM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,2);
 OuterP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,1);
 OuterM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,1);
 InnerP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,1);
 InnerM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,1);
 MA2 = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,0,2);
 MA1 = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,0,1);


//---added-----------------------
   //�N���[�Y�I�[�_�[
   PosCheck(MAGIC);
//---added-----------------------


   // �����|�W�V�����̃G�O�W�b�g
   if(
       (( MA2 <= Close[2] && Close[1] < MA1 ) ||( OuterM2 <= Close[2] && Close[1] < OuterM1 )) 
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // ����|�W�V�����̃G�O�W�b�g
   if(
       (( Close[2] <= MA2 && MA1 < Close[1] )||( Close[2] <= OuterP2 && OuterP1 < Close[1] )) 
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new


//---added-----------------------      
   //�G���g���[�I�[�_�[   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

   // �����G���g���[
   if(    Close[2] <= InnerM2
      &&  InnerM1 < Close[1]
      &&  Close[1] <=  MA1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // ����G���g���[
   if(    InnerP2 <= Close[2]
      &&  Close[1] < InnerP1
      &&  MA1 <= Close[1]
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}