#define MAGIC 1192

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = " ";
extern int TP = 50;
extern int LC = 1500;
//�V�����o�[�̊J�n���ɏ������s��
extern bool OpenPriceOnly = true;
int previousBar = -1;

int TicketL = 0; // ���������̌��ʂ��L���b�`����ϐ�
int TicketS = 0; // ���蒍���̌��ʂ��L���b�`����ϐ�
int ExitL = 0; // �����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�
int ExitS = 0; // ����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�

double Heiken_Open_2 = 0; /*2 �{�O�̃o�[�̕��ϑ��̎n�l�ɕϐg�����@�@
�@�@�@�@�@�@�@�@�@�@�@�@�@ iCustom �֐���������ϐ�*/
double Heiken_Close_2 = 0; /*2 �{�O�̃o�[�̕��ϑ��̏I�l�ɕϐg����
�@�@�@�@�@�@�@�@�@�@�@�@�@ iCustom �֐���������ϐ�*/
double Heiken_Open_1 = 0; /*1 �{�O�̃o�[�̕��ϑ��̎n�l�ɕϐg����
�@�@�@�@�@�@�@�@�@�@�@�@�@iCustom �֐���������ϐ�*/
double Heiken_Close_1 = 0; /*1 �{�O�̃o�[�̕��ϑ��̏I�l�ɕϐg����
                          iCustom �֐���������ϐ�*/


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

   Heiken_Open_2 = iCustom(NULL,0,"Heiken Ashi",0,2);
   Heiken_Close_2 = iCustom(NULL,0,"Heiken Ashi",3,2);
   Heiken_Open_1 = iCustom(NULL,0,"Heiken Ashi",0,1);
   Heiken_Close_1 = iCustom(NULL,0,"Heiken Ashi",3,1);
   
//---added-----------------------
   //�N���[�Y�I�[�_�[
   PosCheck(MAGIC);
//---added-----------------------

   // �����|�W�V�����̃G�O�W�b�g
   if(   Heiken_Open_2 <= Heiken_Close_2
      && Heiken_Open_1 > Heiken_Close_1
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // ����|�W�V�����̃G�O�W�b�g
   if(   Heiken_Open_2 >= Heiken_Close_2
      && Heiken_Open_1 < Heiken_Close_1
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new


//---added-----------------------      
   //�G���g���[�I�[�_�[   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new


   // �����G���g���[
   if(   Heiken_Open_2 >= Heiken_Close_2
      && Heiken_Open_1 < Heiken_Close_1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // ����G���g���[
   if(   Heiken_Open_2 <= Heiken_Close_2
      && Heiken_Open_1 > Heiken_Close_1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}