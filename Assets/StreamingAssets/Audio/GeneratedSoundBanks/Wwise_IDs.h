/////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Audiokinetic Wwise generated include file. Do not edit.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __WWISE_IDS_H__
#define __WWISE_IDS_H__

#include <AK/SoundEngine/Common/AkTypes.h>

namespace AK
{
    namespace EVENTS
    {
        static const AkUniqueID PLAY_2D_AMBIENCE_LOOP = 706595652U;
        static const AkUniqueID PLAY_COMBAT_MUSIC = 3155474038U;
        static const AkUniqueID PLAY_PLAYER_BOOSTER = 142245832U;
        static const AkUniqueID PLAY_PLAYER_BREATHE = 2118095383U;
        static const AkUniqueID PLAY_PLAYER_FS = 4078825889U;
        static const AkUniqueID PLAY_PLAYER_FS_RUN_L = 3625340534U;
        static const AkUniqueID PLAY_PLAYER_FS_RUN_R = 3625340520U;
        static const AkUniqueID PLAY_PLAYER_GRAPPLE_HIT = 780547719U;
        static const AkUniqueID PLAY_PLAYER_GRAPPLE_SHOOT = 1884037509U;
        static const AkUniqueID PLAY_PLAYER_JUMP = 562256996U;
        static const AkUniqueID PLAY_PLAYER_SPIN_ATTACK = 213519327U;
        static const AkUniqueID PLAY_PLAYER_SWORD_HIT = 2116655569U;
        static const AkUniqueID PLAY_PLAYER_SWORD_HIT_POWERFUL = 2812374800U;
        static const AkUniqueID PLAY_PLAYER_SWORD_SLASH = 4003404733U;
        static const AkUniqueID PLAY_PLAYER_VOC_ATTACK = 1786226075U;
        static const AkUniqueID PLAY_PLAYER_VOC_DEATH = 1543233419U;
        static const AkUniqueID PLAY_PLAYER_VOC_GRAPPLE_PULL = 1641970538U;
        static const AkUniqueID PLAY_PLAYER_VOC_JUMP = 3830010507U;
        static const AkUniqueID PLAY_PLAYER_VOC_TAKE_HIT = 3730000400U;
        static const AkUniqueID PLAY_PLAYER_VOC_TAKE_HIT_SOFT = 2806366063U;
        static const AkUniqueID PLAY_TEST_SOUND = 3211564518U;
        static const AkUniqueID PLAY_TITAN_ENGINE_LP = 2201492632U;
        static const AkUniqueID PLAY_TITAN_ENGINE_STOP = 4256576244U;
        static const AkUniqueID PLAY_TITAN_FS = 487948562U;
        static const AkUniqueID PLAY_TITAN_FS_L = 2390231879U;
        static const AkUniqueID PLAY_TITAN_FS_R = 2390231897U;
        static const AkUniqueID PLAY_TITAN_LANTERN_ATTACK = 1409958524U;
        static const AkUniqueID PLAY_TITAN_LANTERN_ATTACK_SEQ = 1842908424U;
        static const AkUniqueID PLAY_TITAN_LANTERN_CHARGE = 2713252876U;
        static const AkUniqueID PLAY_TITAN_LASER_AIM = 1726608006U;
        static const AkUniqueID PLAY_TITAN_LASER_SHOT = 1296203451U;
        static const AkUniqueID PLAY_TITAN_MISSILE_EXPLODE = 3892312811U;
        static const AkUniqueID PLAY_TITAN_MISSILE_SHOT = 3166948436U;
        static const AkUniqueID PLAY_TITAN_SWORD_ATTACK_CHARGE = 3830687480U;
        static const AkUniqueID PLAY_TITAN_SWORD_ATTACK_HIT = 1250704139U;
        static const AkUniqueID PLAY_TITAN_TRAMPLE_FOOT = 1282535387U;
        static const AkUniqueID PLAY_TITAN_TRAMPLE_VOC = 3060992713U;
        static const AkUniqueID PLAY_TITAN_VOC_GENERIC = 3131183803U;
        static const AkUniqueID STOP_2D_AMBIENCE_LOOP = 1752755706U;
        static const AkUniqueID STOP_COMBAT_MUSIC = 970928956U;
        static const AkUniqueID STOP_TITAN_MISSILE_LOOP = 930574960U;
    } // namespace EVENTS

    namespace STATES
    {
        namespace PLAYERSTATE
        {
            static const AkUniqueID GROUP = 3285234865U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID PLAYERALIVE = 2557321869U;
                static const AkUniqueID PLAYERDEAD = 2356585300U;
            } // namespace STATE
        } // namespace PLAYERSTATE

        namespace SLOMO
        {
            static const AkUniqueID GROUP = 4274655655U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID SLOMOOFF = 3568539374U;
                static const AkUniqueID SLOMOON = 1603814480U;
            } // namespace STATE
        } // namespace SLOMO

        namespace TITANSTATE
        {
            static const AkUniqueID GROUP = 635115884U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID TITANALIVE = 3775854796U;
                static const AkUniqueID TITANDEAD = 3970465383U;
            } // namespace STATE
        } // namespace TITANSTATE

    } // namespace STATES

    namespace SWITCHES
    {
        namespace BREATHEINOUT
        {
            static const AkUniqueID GROUP = 3602124287U;

            namespace SWITCH
            {
                static const AkUniqueID IN = 1752637612U;
                static const AkUniqueID OUT = 645492555U;
            } // namespace SWITCH
        } // namespace BREATHEINOUT

        namespace MUSIC_PROGRESS
        {
            static const AkUniqueID GROUP = 4150154280U;

            namespace SWITCH
            {
                static const AkUniqueID ONE = 1064933119U;
                static const AkUniqueID TWO = 678209053U;
            } // namespace SWITCH
        } // namespace MUSIC_PROGRESS

    } // namespace SWITCHES

    namespace GAME_PARAMETERS
    {
        static const AkUniqueID PLAYER_BUS_VOLUME = 688725058U;
        static const AkUniqueID TITAN_BUS_VOLUME = 419602667U;
    } // namespace GAME_PARAMETERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
        static const AkUniqueID MAIN = 3161908922U;
    } // namespace BANKS

    namespace BUSSES
    {
        static const AkUniqueID _2DAMBIENCE = 309309195U;
        static const AkUniqueID _2DAMBIENTBEDS = 4152869693U;
        static const AkUniqueID _3DAMBIENCE = 1301074112U;
        static const AkUniqueID AMBIENTBEDS = 1182634443U;
        static const AkUniqueID AMBIENTMASTER = 1459460693U;
        static const AkUniqueID MASTER_AUDIO_BUS = 3803692087U;
        static const AkUniqueID MUSIC = 3991942870U;
        static const AkUniqueID PLAYERCLOTH = 765206498U;
        static const AkUniqueID PLAYERFS = 3691462299U;
        static const AkUniqueID PLAYERLOCOMOTION = 2343802269U;
        static const AkUniqueID PLAYERMASTER = 3538689948U;
        static const AkUniqueID TITANMASTER = 650398475U;
    } // namespace BUSSES

    namespace AUX_BUSSES
    {
        static const AkUniqueID OUTDOOR = 144697359U;
        static const AkUniqueID REVERBS = 3545700988U;
    } // namespace AUX_BUSSES

    namespace AUDIO_DEVICES
    {
        static const AkUniqueID NO_OUTPUT = 2317455096U;
        static const AkUniqueID SYSTEM = 3859886410U;
    } // namespace AUDIO_DEVICES

}// namespace AK

#endif // __WWISE_IDS_H__
