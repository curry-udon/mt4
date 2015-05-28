// �}�W�b�N�i���o�[�̒�`
#define MAGIC 1234

// �p�����[�^�[�̐ݒ�//
extern int Tenkan = 6; // �]�����̊��Ԑݒ�
extern int Kijun = 26; // ����̊��Ԑݒ�
extern int Senkou = 52; // ��s���̊��Ԑݒ�

extern double Lots = 1.0; // ������b�g��
extern int Slip = 10; // ���e�X���b�y�[�W��
extern string Comments = " "; // �R�����g

// �ϐ��̐ݒ�//
int Ticket_L = 0; // ���������̌��ʂ��L���b�`����ϐ�
int Ticket_S = 0; // ���蒍���̌��ʂ��L���b�`����ϐ�
int Exit_L = 0; // �����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�
int Exit_S = 0; // ����|�W�V�����̌��ϒ����̌��ʂ��L���b�`����ϐ�

double SenkouA_2 = 0; /*2 �{�O�̃o�[�̐�s�X�p��A �ɕϐg����iCustom
�@�@�@�@�@�@�@�@�@�@�@�@�@�֐���������ϐ�*/
double SenkouB_2 = 0; /*2 �{�O�̃o�[�̐�s�X�p��B �ɕϐg����iCustom
�@�@�@�@�@�@�@�@�@�@�@�@�@�֐���������ϐ�*/
double SenkouA_1 = 0; /*1 �{�O�̃o�[�̐�s�X�p��A �ɕϐg����iCustom
�@�@�@�@�@�@�@�@�@�@�@�@�@�֐���������ϐ�*/
double SenkouB_1 = 0; /*1 �{�O�̃o�[�̐�s�X�p��B �ɕϐg����iCustom
�@�@�@�@�@�@�@�@�@�@�@�@�@�֐���������ϐ�*/


int start()
{

   SenkouA_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,2);
   SenkouB_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,2);
   SenkouA_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,1);
   SenkouB_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,1);

   // �����|�W�V�����̃G�O�W�b�g
   if( ( SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2] )
      && SenkouA_1 > Close[1] && SenkouB_1 > Close[1]
      && ( Ticket_L != 0 && Ticket_L != -1 ))
      {
         Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
         if( Exit_L == 1 ) {Ticket_L = 0;}
      }
      
   // ����|�W�V�����̃G�O�W�b�g
   if( ( SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2] )
      && SenkouA_1 < Close[1] && SenkouB_1 < Close[1]
      && ( Ticket_S != 0 && Ticket_S != -1 ))
      {
         Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
         if( Exit_S == 1 ) {Ticket_S = 0;}
      }
      
   // �����G���g���[
   if( ( SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2] )
      && SenkouA_1 < Close[1] && SenkouB_1 < Close[1]
      && ( Ticket_L == 0 || Ticket_L == -1 )
      && ( Ticket_S == 0 || Ticket_S == -1 ))
      {
         Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // ����G���g���[
   if( ( SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2] )
      && SenkouA_1 > Close[1] && SenkouB_1 > Close[1]
      && ( Ticket_S == 0 || Ticket_S == -1 )
      && ( Ticket_L == 0 || Ticket_L == -1 ))
      {
         Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
   
return(0);
}