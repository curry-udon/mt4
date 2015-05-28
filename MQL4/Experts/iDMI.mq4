
// �}�W�b�N�i���o�[�̒�`
#define MAGIC 3986

// �p�����[�^�[�̐ݒ�//
extern int parameter1=240; //ADXPeriod=240

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "ADX";
extern int TP = 50;
extern int LC = 1500;

// �ϐ��̐ݒ�//
int TicketL = 0; // ���������̌��ʂ��L���b�`����ϐ�
int TicketS = 0; // ���蒍���̌��ʂ��L���b�`����ϐ�
int ExitL = 0; // �����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�
int ExitS = 0; // ����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�


double pDI2 = 0;
double mDI2 = 0;
double pDI1 = 0;
double mDI1 = 0;


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


 pDI2 = iCustom(NULL,0,"ADX",parameter1,1,2);
 mDI2 = iCustom(NULL,0,"ADX",parameter1,2,2);
 pDI1 = iCustom(NULL,0,"ADX",parameter1,1,1);
 mDI1 = iCustom(NULL,0,"ADX",parameter1,2,1);

//---added-----------------------
   //�N���[�Y�I�[�_�[
   PosCheck(MAGIC);
//---added-----------------------

   // �����|�W�V�����̃G�O�W�b�g
   if(    mDI2 <= pDI2
      &&  pDI1 <  mDI1
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // ����|�W�V�����̃G�O�W�b�g
   if(    pDI2 <= mDI2
      &&  mDI1 <  pDI1
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new

//---added-----------------------      
   //�G���g���[�I�[�_�[   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

      
      
   // �����G���g���[
   if(    pDI2 <= mDI2
      &&  mDI1 <  pDI1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // ����G���g���[
   if(    mDI2 <= pDI2
      &&  pDI1 <  mDI1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}