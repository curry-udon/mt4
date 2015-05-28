
// �}�W�b�N�i���o�[�̒�`
#define MAGIC 3986

// �p�����[�^�[�̐ݒ�//


extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Eagle1";
extern int TP = 50;
extern int LC = 1500;

// �ϐ��̐ݒ�//
int TicketL = 0; // ���������̌��ʂ��L���b�`����ϐ�
int TicketS = 0; // ���蒍���̌��ʂ��L���b�`����ϐ�
int ExitL = 0; // �����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�
int ExitS = 0; // ����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�

double PP_2 = 0;
double S1_2 = 0;
double R1_2 = 0;
double S2_2 = 0;
double R2_2 = 0;
double S3_2 = 0;
double R3_2 = 0;
double PP_1 = 0;
double S1_1 = 0;
double R1_1 = 0;
double S2_1 = 0;
double R2_1 = 0;
double S3_1 = 0;
double R3_1 = 0;

//�V�����o�[�̊J�n���ɏ������s��
	extern bool OpenPriceOnly = true;
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

 PP_2 = iCustom(NULL,0,"Pivot_v1",0,2);
 R1_2 = iCustom(NULL,0,"Pivot_v1",1,2);
 S1_2 = iCustom(NULL,0,"Pivot_v1",2,2);
 R2_2 = iCustom(NULL,0,"Pivot_v1",3,2);
 S2_2 = iCustom(NULL,0,"Pivot_v1",4,2);
 R3_2 = iCustom(NULL,0,"Pivot_v1",5,2);
 S3_2 = iCustom(NULL,0,"Pivot_v1",6,2);

 PP_1 = iCustom(NULL,0,"Pivot_v1",0,1);
 R1_1 = iCustom(NULL,0,"Pivot_v1",1,1);
 S1_1 = iCustom(NULL,0,"Pivot_v1",2,1);
 R2_1 = iCustom(NULL,0,"Pivot_v1",3,1);
 S2_1 = iCustom(NULL,0,"Pivot_v1",4,1);
 R3_1 = iCustom(NULL,0,"Pivot_v1",5,1);
 S3_1 = iCustom(NULL,0,"Pivot_v1",6,1);

//---added-----------------------
   //�N���[�Y�I�[�_�[
   PosCheck(MAGIC);
//---added-----------------------

   // �����|�W�V�����̃G�O�W�b�g
   if(( (S2_2 <= Close[2] &&  Close[1] <  S2_1) 
      ||(S1_2 <= Close[2] &&  Close[1] <  S1_1)
      ||(PP_2 <= Close[2] &&  Close[1] <  PP_1) 
      ||(R1_2 <= Close[2] &&  Close[1] <  R1_1) 
      ||(R2_2 <= Close[2] &&  Close[1] <  R2_1) )
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // ����|�W�V�����̃G�O�W�b�g
   if(( (Close[2] <= R2_2 &&  R2_1 < Close[1]) 
      ||(Close[2] <= R1_2 &&  R1_1 < Close[1])      
      ||(Close[2] <= PP_2 &&  PP_1 < Close[1])  
      ||(Close[2] <= S1_2 &&  S1_1 < Close[1])  
      ||(Close[2] <= S2_2 &&  S2_1 < Close[1])   )
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new

//---added-----------------------      
   //�G���g���[�I�[�_�[   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

 
   // �����G���g���[
   if(    Close[2] <= S2_2
      &&  S2_1 < Close[1]
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
   // ����G���g���[
   if(        R2_2 <= Close[2]
      &&  Close[1] <  R2_1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Red);
      }
      /**/
      
return(0);
}