
// �}�W�b�N�i���o�[�̒�`
#define MAGIC 3986

// �p�����[�^�[�̐ݒ�//
extern int MA_Period=24;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int Applied_Price=0;
extern double Deviation1=1.0;
extern double Deviation2=1.5;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Eagle1";
extern int TP = 50;
extern int LC = 3000;

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
	extern bool OpenPriceOnly = true;
	int previousBar = -1;

int start()
{
	/*
	//�����|�W�V�����̗��v�m��
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() + TP * Point <= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Red);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//����|�W�V�����̗��v�m��
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() - TP * Point >= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Blue);
	if( ExitS ==1 ) {TicketS = 0;}
	} 
	*/

	//�����|�W�V�����̃��X�J�b�g
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() - LC * Point >= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Red);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//����|�W�V�����̃��X�J�b�g
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() + LC * Point <= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Blue);
	if( ExitS ==1 ) {TicketS = 0;}
	} 

	//�V�����o�[�̊J�n���ɏ������s��
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;



 OuterP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,2);
 OuterM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,2);
 InnerP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,2);
 InnerM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,2);
 OuterP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,1);
 OuterM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,1);
 InnerP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,1);
 InnerM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,1);
 MA2 = iCustom(NULL,0,"Moving Averages",MA_Period,MA_Shift,MA_Method,0,2);
 MA1 = iCustom(NULL,0,"Moving Averages",MA_Period,MA_Shift,MA_Method,0,1);

   // �����|�W�V�����̃G�O�W�b�g
   if(
       (( Close[2] <= MA2 &&  MA1 < Close[1] )
      ||( OuterM2 <= Close[2] && Close[1] < OuterM1 )) 
      && ( TicketL != 0 && TicketL != -1 )
     )
      {
         ExitL = OrderClose(TicketL,Lots,Bid,Slip,Blue);
         if( ExitL == 1 ) {TicketL = 0;}
      }
      
   // ����|�W�V�����̃G�O�W�b�g
   if(
       (( MA2 <= Close[2] && Close[1] < MA1 )
      ||( Close[2] <= OuterP2 && OuterP1 < Close[1] )) 
      && ( TicketL != 0 && TicketL != -1 )
     )
      {
         ExitS = OrderClose(TicketS,Lots,Ask,Slip,Red);
         if( ExitS == 1 ) {TicketS = 0;}
      }
      
   // �����G���g���[
   if(    Close[2] <= InnerM2
      &&  InnerM1 < Close[1]
      &&  Close[1] <=  MA1
      && ( TicketL == 0 || TicketL == -1 )
      && ( TicketS == 0 || TicketS == -1 ))
      {
         TicketL = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0, Comments,MAGIC,0,Red);
      }
      
   // ����G���g���[
   if(    InnerP2 <= Close[2]
      &&  Close[1] < InnerP1
      &&  MA1 <= Close[1]
      && ( TicketS == 0 || TicketS == -1 )
      && ( TicketL == 0 || TicketL == -1 ))
      {
         TicketS = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
return(0);
}