using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using ClassLibrary1;
using System.IO;
using System.Xml;
using System.Globalization;

namespace Simulator
{
    
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            //Aircraft state array for the whole trajectory, 1-6 states of the matrix X (states: x,y,h,TAS,hdg,mass), 
            //7-10 states of the matrix U (inputs: thrust, bank, pitch, drag),
            //according to design document and Poretta et al. (2008). Other values are currently unused.
            //86400 values represents a day of simulation expressed in seconds.
            Array ACStateTrajectory = Array.CreateInstance(typeof(Int32), 20, 86400);

            //Current aircraft state (with inputs also)
            //Array ACState = Array.CreateInstance(typeof(double), 20);
            //Initial aircraft state. To be read from the flight plan.
            Array ACStateInitial = Array.CreateInstance(typeof(Int32), 20);
            //New aircraft state that follows from the current state
            Array ACStateNew = Array.CreateInstance(typeof(double), 20);

            //Wind components along x,y, and h axis.
            //Array Wind = Array.CreateInstance(typeof(Int32), 3);

            
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            //Application.Run(new RadarScreen());
            Application.Run(new SetUp());
        }

        
    }
    
    public class TrajectoryGenerator
    {
        double g0 = 9.80665; //Acceleration due to gravity at MSL, m/s^2
        double Vtol = 1; //Tolerated speed difference from nominal
        double Htol = 15; //Tolerated altitude difference from nominal
        TEM tem = new TEM();
        GeodeticTransforms GT = new GeodeticTransforms();
        public double RefPointLat = 0.7766715171374766; //Reference point for conversion from geodetic to ENU coords
        public double RefPointLon = 0.2879793265790644; //Reference point for conversion from geodetic to ENU coords
        

        /// <summary>
        /// Updates the aircraft's state according to model from Poretta et al. (2008).
        /// </summary>
        /// <param name="ACState">Current aircraft state. {x[m],y[m],z[m],TAS[m/s],hdg[rad],mass[kg]}</param>
        /// <param name="Wind">Wind components along the x,y,z axes.</param>
        /// <param name="S">Reference wing area of the aircraft. [m2]</param>
        /// <param name="rho">Air density at current aircraft altitude. [kg/m3]</param>
        /// <param name="FF">Fuel consumption. [kg/s]</param>
        /// <param name="CL">Lift coefficient. [dimensionless]</param>
        /// <returns>New aircraft state. {x,y,z,TAS,hdg,mass} </returns>
        public Array ACStateUpdate(Array ACCurState, double[] Wind, double S, double rho, double FF, double CL)
        {
            double[] ACState = new double[11];
            Array ACStateUpdated = Array.CreateInstance(typeof(double), 20);
            ACState[1] = (double)ACCurState.GetValue(1);
            ACState[2] = (double)ACCurState.GetValue(2);
            ACState[3] = (double)ACCurState.GetValue(3);
            ACState[4] = (double)ACCurState.GetValue(4);
            ACState[5] = (double)ACCurState.GetValue(5);
            ACState[6] = (double)ACCurState.GetValue(6);
            ACState[7] = (double)ACCurState.GetValue(7); 
            ACState[8] = (double)ACCurState.GetValue(8);
            ACState[9] = (double)ACCurState.GetValue(9);
            ACState[10] = (double)ACCurState.GetValue(10);

            ACStateUpdated.SetValue(ACState[1] + ACState[4] * Math.Cos(ACState[5]) * Math.Cos(ACState[9]) + Wind[1],1);
            ACStateUpdated.SetValue(ACState[2] + ACState[4] * Math.Sin(ACState[5]) * Math.Cos(ACState[9]) + Wind[2],2);
            ACStateUpdated.SetValue(ACState[3] + ACState[4] * Math.Sin(ACState[9]) + Wind[3],3);
            ACStateUpdated.SetValue(ACState[4] - ((ACState[10] * S * rho * ACState[4] * ACState[4]) / (2 * ACState[6])) - g0 * Math.Sin(ACState[9]) + ACState[7] / ACState[6],4);
            ACStateUpdated.SetValue(ACState[5] + (CL * S * rho * ACState[4] * Math.Sin(ACState[8])) / (2 * ACState[6]),5);
            ACStateUpdated.SetValue(ACState[6] - FF,6);

            ACStateUpdated.SetValue(ACState[7], 7);
            ACStateUpdated.SetValue(ACState[8], 8);
            ACStateUpdated.SetValue(ACState[9], 9);
            ACStateUpdated.SetValue(ACState[10], 10);

            return ACStateUpdated;
        }

        public Array Generate(string BADAfile, XmlDocument FlightPlan, double[] Meteo, string BadaOPF, string BadaAPF, bool FourD, double AbsoluteTime, bool Civil)
        {
            // FourD = false; //REMOVE THIS ONCE 4D OPS ARE COMPLETELY IMPLEMENTED!!!
            
            // Initial aircraft state. To be read from the flight plan.
            // Array ACStateInitial = Array.CreateInstance(typeof(double), 20);
            // ACStateInitial = ReadInitialState(FlightPlan);

            // Array ACCurrentState = Array.CreateInstance(typeof(double), 20);
            // ACCurrentState = ACStateInitial;

            string ACCmode = "C"; //Acceleration mode: (A)cceleration, (C)onstant, (D)ecceleration.
            string CLmode = "L"; //Climb mode: (C)limb, (L)evel, (D)escent
            string ConfigMode = "CL"; //Aircraft configuration mode: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
            string SpeedMode = "C"; //Speed hold mode: (C)AS or (M)ach
            // bool Holding = false; //Is aircraft in holding?
            bool Tropopause = false; //Is aircraft above tropopause?
            int WPTi = 1; //Waypoint index. It marks the next waypoint in the waypoint list.
            double FF = 0; //Fuel flow
            double DistToNext = 0; //Distance to next waypoint
            double TurnRadius = 0; //Aircraft turn radius for current speed
            bool StillFlying = true;
            int MaximumFlightTime = 14400; //maximum flight duration is 4h, should be enough for all realistic scenarios.
                                           //It can be increased on a faster computer or if the main traj prediction loop is optimized.
                                           //Right now excessive flight times make trajectory prediction too slow.

            //Set of waypoints is read from the flight plan
            WPT[] waypts;
            waypts = ReadFlightPlan(FlightPlan);

            // OPFReaderforBADA OPFreader = new OPFReaderforBADA(); //Read ac performance data
            // OPFreader.ReadOPF(BadaOPF);

            // APFReaderforBADA APFreader = new APFReaderforBADA(); //Read airline operations data
            // APFreader.ReadAPF(BadaAPF);

            // GPFReaderforBADA GPFreader = new GPFReaderforBADA(); //Read general performance data
            // GPFreader.ReadGPF(BADAfile);

            OperationsModel OpsModel = new OperationsModel(); //Operations model
            
            // ReadElevation ElevationRdr = new ReadElevation(); //Read elevation data. NOT Implemented yet, currently returns 0.
            // double[] ElevationData = ElevationRdr.LoadElevationData("elevation.dem"); //Maybe it should be read into an array instead

            double[] Wind = { 0, Meteo[2], Meteo[3], Meteo[4] }; //Copy only wind info (x,y,z components) from the Meteo array.
            Array ACStateArchive = Array.CreateInstance(typeof(double),40,MaximumFlightTime); 
            int time = 0;
            while (StillFlying) //MAIN TRAJECTORY PREDICTION LOOP
            {
                
                
                //1. Determine conditions at current alt for current meteo
                AtmCon AtmConditions = new AtmCon();
                AtmConditions = ConditionsAtAlt(Meteo, System.Convert.ToDouble(ACCurrentState.GetValue(3)));

                //2. Determine altitudes (Hp, geodetic, AGL)
                // double h_AGL = GeodetictoAGL(ElevationData, ACCurrentState);
                if (AtmConditions.Hp > 11000) { Tropopause = true; } else { Tropopause = false; }

                //3. Determine all speeds (TAS to CAS to Mach)
                SpeedConversions SpdCon = new SpeedConversions();
                double CAScurrent = SpdCon.TAStoCAS(AtmConditions.Pressure, AtmConditions.Density, System.Convert.ToDouble(ACCurrentState.GetValue(4)));
                double MACHcurrent = SpdCon.TAStoMach(System.Convert.ToDouble(ACCurrentState.GetValue(4)), AtmConditions.Temperature);
                double TransAlt = SpdCon.TransitionAltitude(APFreader.M_cl, APFreader.V_cl2 * 0.5144);
                if (AtmConditions.Hp > TransAlt) { SpeedMode = "M"; } else { SpeedMode = "C"; }

                //4. Determine phase of flight: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
                CLmode = CLModeSet((double)ACCurrentState.GetValue(3), waypts[WPTi].z, CLmode);
                ConfigMode = ConfigModeSet(GPFreader, OPFreader, AtmConditions.Hp, ElevationData, CAScurrent, CLmode);

                //5. Determine acceleration mode: (A)ccelerating, (C)onstant, (D)ecelerating, and desired TAS
                double TASDesired = 0;
                // if (waypts[WPTi].IsTASInstructed) //TAS is given by ATC
                // {
                    // TASDesired = waypts[WPTi].InstructedTAS;
                // }
                // else if (waypts[WPTi].IsCASInstructed)
                // {
                    // TASDesired = SpdCon.CAStoTAS(AtmConditions.Pressure, AtmConditions.Density, waypts[WPTi].InstructedCAS);
                // }
                // else if (waypts[WPTi].IsMachInstructed)
                // {
                    // TASDesired = SpdCon.MachtoTAS(waypts[WPTi].InstructedMach, AtmConditions.Temperature);
                // }
                // else //normal speed schedule
                // {
                    TASDesired = DesiredTAS(GPFreader, APFreader, OPFreader, OpsModel, SpdCon, FourD, CLmode, System.Convert.ToDouble(ACCurrentState.GetValue(6)), AtmConditions, ConfigMode);
                // }
                ACCmode = ACCModeSet((double)ACCurrentState.GetValue(4), TASDesired, ACCmode);

                //6. Determine energy share factor
                double ESF = tem.ESF(MACHcurrent, AtmConditions.Temperature, Meteo[0] - 288.15, ACCmode, CLmode, SpeedMode, Tropopause);

                //7. Determine inputs
                //7.a Lift and Drag
                double CLift = OpsModel.LiftCoefficient((double)ACCurrentState.GetValue(6), AtmConditions.Density, OPFreader.WingArea, (double)ACCurrentState.GetValue(4), (double)ACCurrentState.GetValue(8));
                ACCurrentState.SetValue(DragCoefficient(OPFreader, OpsModel, ConfigMode, CLift), 10); //Sets drag coefficient: u(4)
                //7.b Thrust
                ACCurrentState.SetValue(ThrustSet(GPFreader, OpsModel, OPFreader, ACCurrentState, AtmConditions, CLmode, TASDesired, ACCmode, Meteo, ConfigMode, waypts, WPTi, ESF), 7); // Sets thrust: u(1)
                //7.c Pitch angle
                ACCurrentState.SetValue(PitchSet(OPFreader, GPFreader, ACCurrentState, waypts[WPTi].z, ESF, AtmConditions), 9);
                //7.d Bank angle
                ACCurrentState.SetValue(BankSet(OPFreader, GPFreader, ACCurrentState, AtmConditions, waypts, WPTi, ConfigMode, Holding, Meteo), 8);

                //8. Fuel consumption
                FF = OpsModel.FuelConsumption((double)ACCurrentState.GetValue(4), (double)ACCurrentState.GetValue(7), AtmConditions.Hp, OPFreader.C_f1, OPFreader.C_f2, OPFreader.C_f3, OPFreader.C_f4, OPFreader.C_fcr, OPFreader.EngType,CLmode);   

                //9. Update AC state

                ACStateArchive.SetValue(ACCurrentState.GetValue(1), 1, time); //These are used to temporary save the whole trajectory
                ACStateArchive.SetValue(ACCurrentState.GetValue(2), 2, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(3), 3, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(4), 4, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(5), 5, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(6), 6, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(7), 7, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(8), 8, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(9), 9, time);
                ACStateArchive.SetValue(ACCurrentState.GetValue(10), 10, time);
                ACStateArchive.SetValue(TASDesired, 11, time);
                ACStateArchive.SetValue(ESF, 12, time);
                ACStateArchive.SetValue(CAScurrent, 13, time);
                ACStateArchive.SetValue(MACHcurrent, 14, time);

                double WindDir = Math.Atan2(Meteo[3], Meteo[2]);
                double WindSpd = Math.Sqrt(Meteo[2] * Meteo[2] + Meteo[3] * Meteo[3]);
                double WCA = Math.Asin(Math.Sin((double)ACCurrentState.GetValue(5) - WindDir) * WindSpd / (double)ACCurrentState.GetValue(4));
                double Track = (double)ACCurrentState.GetValue(5) - WCA;
                ACStateArchive.SetValue(Track, 15, time);
                ACStateArchive.SetValue(WPTi, 16, time);
                ACStateArchive.SetValue(waypts[WPTi].x, 17, time);
                ACStateArchive.SetValue(waypts[WPTi].y, 18, time);
                ACStateArchive.SetValue(waypts[WPTi].z, 19, time);
                ACStateArchive.SetValue(waypts[WPTi].t, 20, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedCAS, 21, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedHeading, 22, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedMach, 23, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedROCD, 24, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedTAS, 25, time);
                // ACStateArchive.SetValue(waypts[WPTi].InstructedTrack, 26, time);

                // if (waypts[WPTi].IsHeadingInstructed)
                // {
                    // ACStateArchive.SetValue(1, 27, time);
                // }
                // else
                // {
                    // ACStateArchive.SetValue(0, 27, time);
                // }
                // if (waypts[WPTi].IsTASInstructed)
                // {
                    // ACStateArchive.SetValue(1, 28, time);
                // }
                // else
                // {
                    // ACStateArchive.SetValue(0, 28, time); //29 is used below for GS
                // }

                //Update AC state
                ACCurrentState = ACStateUpdate(ACCurrentState, Wind, OPFreader.WingArea, AtmConditions.Density, FF, CLift);
                
                //Calculate groundspeed
                double oldX = (double)ACStateArchive.GetValue(1, time);
                double oldY = (double)ACStateArchive.GetValue(2, time);
                double GS = Math.Sqrt(Math.Pow(oldX - (double)ACCurrentState.GetValue(1), 2) + Math.Pow(oldY - (double)ACCurrentState.GetValue(2), 2));
                ACStateArchive.SetValue(GS, 29, time);

                //10. Reached next waypoint?
                DistToNext = Math.Sqrt(Math.Pow((double)ACCurrentState.GetValue(1) - waypts[WPTi].x, 2) + Math.Pow((double)ACCurrentState.GetValue(2) - waypts[WPTi].y, 2));
                TurnRadius = (double)ACCurrentState.GetValue(4)*(double)ACCurrentState.GetValue(4)/(g0*Math.Tan(GPFreader.phi_nomciv));
                if (waypts[WPTi].flyover == 1 && DistToNext < TurnRadius * 0.1)
                {
                    WPTi = WPTi + 1;
                }
                else if (waypts[WPTi].flyover == 0 && DistToNext < TurnRadius)
                {
                    WPTi = WPTi + 1;
                }
                //11. Reached last waypoint?
                if (WPTi > waypts.GetUpperBound(0)) { StillFlying = false; }
                time = time + 1;
                if (time >= MaximumFlightTime -1) { StillFlying = false; }
            } // END OF LOOP
            /*
            using (StreamWriter file = new StreamWriter("putanja.txt")) //saving current trajectory into a file.
            {
                for (int ii = 0; ii <= (time-1); ii++)
                {

                    file.Write(ACStateArchive.GetValue(1, ii).ToString() + ";" + ACStateArchive.GetValue(2, ii).ToString() + ";" + ACStateArchive.GetValue(3, ii).ToString() + ";" + ACStateArchive.GetValue(4, ii).ToString() + ";" + ACStateArchive.GetValue(5, ii).ToString() + ";" + ACStateArchive.GetValue(6, ii).ToString() + ";" + ACStateArchive.GetValue(7, ii).ToString() + ";" + ACStateArchive.GetValue(8, ii).ToString() + ";" + ACStateArchive.GetValue(9, ii).ToString() + ";" + ACStateArchive.GetValue(10, ii).ToString() + ";" +  ACStateArchive.GetValue(11, ii).ToString() + ";" + ACStateArchive.GetValue(12, ii).ToString() +  "\r\n");
                    
                }
            }
            */
            Array Trajectory = Array.CreateInstance(typeof(double), 40, time);
            for (int i = 0; i < 40; i++)
            {
                Array.Copy(ACStateArchive, i * MaximumFlightTime, Trajectory, i * time, time);
            }
            
            return Trajectory;
        }

        /// <summary>
        /// Reads flight plan XML file and returns WPT struct array containing all data.
        /// </summary>
        /// <param name="xmlFP">XmlDocument of the flight plan.</param>
        /// <returns></returns>
        public WPT[] ReadFlightPlan(XmlDocument xmlFP)
        {
            XmlNodeList wptno = xmlFP.GetElementsByTagName("WPTno");
            XmlNodeList wptnames = xmlFP.GetElementsByTagName("WPTname");
            XmlNodeList wptx = xmlFP.GetElementsByTagName("coordx");
            XmlNodeList wpty = xmlFP.GetElementsByTagName("coordy");
            XmlNodeList wptz = xmlFP.GetElementsByTagName("coordz");
            XmlNodeList wpttime = xmlFP.GetElementsByTagName("time");
            XmlNodeList wptfo = xmlFP.GetElementsByTagName("flyover");
            XmlNodeList wptInstructedTAS = xmlFP.GetElementsByTagName("InstructedTAS");
            XmlNodeList wptIsTASInstructed = xmlFP.GetElementsByTagName("IsTASInstructed");
            XmlNodeList wptInstructedTrack = xmlFP.GetElementsByTagName("InstructedTrack");
            XmlNodeList wptIsTrackInstructed = xmlFP.GetElementsByTagName("IsTrackInstructed");
            XmlNodeList wptInstructedROCD = xmlFP.GetElementsByTagName("InstructedROCD");
            XmlNodeList wptIsROCDInstructed = xmlFP.GetElementsByTagName("IsROCDInstructed");
            XmlNodeList wptInstructedCAS = xmlFP.GetElementsByTagName("InstructedCAS");
            XmlNodeList wptIsCASInstructed = xmlFP.GetElementsByTagName("IsCASInstructed");
            XmlNodeList wptInstructedMach = xmlFP.GetElementsByTagName("InstructedMach");
            XmlNodeList wptIsMachInstructed = xmlFP.GetElementsByTagName("IsMachInstructed");
            XmlNodeList wptInstructedHeading = xmlFP.GetElementsByTagName("InstructedHeading");
            XmlNodeList wptIsHeadingInstructed = xmlFP.GetElementsByTagName("IsHeadingInstructed");
            XmlNodeList RFFUstr1 = xmlFP.GetElementsByTagName("RFFU-string1"); //Reserved for future use
            XmlNodeList RFFUstr2 = xmlFP.GetElementsByTagName("RFFU-string2");
            XmlNodeList RFFUstr3 = xmlFP.GetElementsByTagName("RFFU-string3");
            XmlNodeList RFFUstr4 = xmlFP.GetElementsByTagName("RFFU-string4");
            XmlNodeList RFFUstr5 = xmlFP.GetElementsByTagName("RFFU-string5");
            XmlNodeList RFFUstr6 = xmlFP.GetElementsByTagName("RFFU-string6");
            XmlNodeList RFFUstr7 = xmlFP.GetElementsByTagName("RFFU-string7");
            XmlNodeList RFFUstr8 = xmlFP.GetElementsByTagName("RFFU-string8");
            XmlNodeList RFFUstr9 = xmlFP.GetElementsByTagName("RFFU-string9");
            XmlNodeList RFFUstr10 = xmlFP.GetElementsByTagName("RFFU-string10");
            XmlNodeList RFFUfloat1 = xmlFP.GetElementsByTagName("RFFU-float1");
            XmlNodeList RFFUfloat2 = xmlFP.GetElementsByTagName("RFFU-float2");
            XmlNodeList RFFUfloat3 = xmlFP.GetElementsByTagName("RFFU-float3");
            XmlNodeList RFFUfloat4 = xmlFP.GetElementsByTagName("RFFU-float4");
            XmlNodeList RFFUfloat5 = xmlFP.GetElementsByTagName("RFFU-float5");
            XmlNodeList RFFUfloat6 = xmlFP.GetElementsByTagName("RFFU-float6");
            XmlNodeList RFFUfloat7 = xmlFP.GetElementsByTagName("RFFU-float7");
            XmlNodeList RFFUfloat8 = xmlFP.GetElementsByTagName("RFFU-float8");
            XmlNodeList RFFUfloat9 = xmlFP.GetElementsByTagName("RFFU-float9");
            XmlNodeList RFFUfloat10 = xmlFP.GetElementsByTagName("RFFU-float10");
            XmlNodeList RFFUbool1 = xmlFP.GetElementsByTagName("RFFU-bool1");
            XmlNodeList RFFUbool2 = xmlFP.GetElementsByTagName("RFFU-bool2");
            XmlNodeList RFFUbool3 = xmlFP.GetElementsByTagName("RFFU-bool3");
            XmlNodeList RFFUbool4 = xmlFP.GetElementsByTagName("RFFU-bool4");
            XmlNodeList RFFUbool5 = xmlFP.GetElementsByTagName("RFFU-bool5");
            XmlNodeList RFFUbool6 = xmlFP.GetElementsByTagName("RFFU-bool6");
            XmlNodeList RFFUbool7 = xmlFP.GetElementsByTagName("RFFU-bool7");
            XmlNodeList RFFUbool8 = xmlFP.GetElementsByTagName("RFFU-bool8");
            XmlNodeList RFFUbool9 = xmlFP.GetElementsByTagName("RFFU-bool9");
            XmlNodeList RFFUbool10 = xmlFP.GetElementsByTagName("RFFU-bool10");

            WPT[] waypoints = new WPT[wptno.Count];
            for (int i = 0; i < wptno.Count; i++)
            {
                double Xpos = System.Convert.ToDouble(wptx[i].InnerText, CultureInfo.InvariantCulture)*0.0174532925199433;
                double Ypos = System.Convert.ToDouble(wpty[i].InnerText, CultureInfo.InvariantCulture)*0.0174532925199433;
                double[] ENUpos = GT.GeodeticToENU(Xpos, Ypos, 0, RefPointLat, RefPointLon, 0);

                waypoints[i].No = System.Convert.ToInt16(wptno[i].InnerText);
                waypoints[i].name = wptnames[i].InnerText;
                waypoints[i].x = ENUpos[0];
                waypoints[i].y = ENUpos[1];
                waypoints[i].z = System.Convert.ToDouble(wptz[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].t = System.Convert.ToDouble(wpttime[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].flyover = System.Convert.ToInt16(wptfo[i].InnerText);
                waypoints[i].InstructedTAS = System.Convert.ToDouble(wptInstructedTAS[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsTASInstructed = bool.Parse(wptIsTASInstructed[i].InnerText);
                waypoints[i].InstructedTrack = System.Convert.ToDouble(wptInstructedTrack[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsTrackInstructed = bool.Parse(wptIsTrackInstructed[i].InnerText);
                waypoints[i].InstructedROCD = System.Convert.ToDouble(wptInstructedROCD[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsROCDInstructed = bool.Parse(wptIsROCDInstructed[i].InnerText);
                waypoints[i].InstructedCAS = System.Convert.ToDouble(wptInstructedCAS[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsCASInstructed = bool.Parse(wptIsCASInstructed[i].InnerText);
                waypoints[i].InstructedMach = System.Convert.ToDouble(wptInstructedMach[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsMachInstructed = bool.Parse(wptIsMachInstructed[i].InnerText);
                waypoints[i].InstructedHeading = System.Convert.ToDouble(wptInstructedHeading[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].IsHeadingInstructed = bool.Parse(wptIsHeadingInstructed[i].InnerText);
                waypoints[i].RFFUstr1 = RFFUstr1[i].InnerText;
                waypoints[i].RFFUstr2 = RFFUstr2[i].InnerText;
                waypoints[i].RFFUstr3 = RFFUstr3[i].InnerText;
                waypoints[i].RFFUstr4 = RFFUstr4[i].InnerText;
                waypoints[i].RFFUstr5 = RFFUstr5[i].InnerText;
                waypoints[i].RFFUstr6 = RFFUstr6[i].InnerText;
                waypoints[i].RFFUstr7 = RFFUstr7[i].InnerText;
                waypoints[i].RFFUstr8 = RFFUstr8[i].InnerText;
                waypoints[i].RFFUstr9 = RFFUstr9[i].InnerText;
                waypoints[i].RFFUstr10 = RFFUstr10[i].InnerText;
                waypoints[i].RFFUfloat1 = float.Parse(RFFUfloat1[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat2 = float.Parse(RFFUfloat2[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat3 = float.Parse(RFFUfloat3[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat4 = float.Parse(RFFUfloat4[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat5 = float.Parse(RFFUfloat5[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat6 = float.Parse(RFFUfloat6[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat7 = float.Parse(RFFUfloat7[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat8 = float.Parse(RFFUfloat8[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat9 = float.Parse(RFFUfloat9[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUfloat10 = float.Parse(RFFUfloat10[i].InnerText, CultureInfo.InvariantCulture);
                waypoints[i].RFFUbool1 = bool.Parse(RFFUbool1[i].InnerText);
                waypoints[i].RFFUbool2 = bool.Parse(RFFUbool2[i].InnerText);
                waypoints[i].RFFUbool3 = bool.Parse(RFFUbool3[i].InnerText);
                waypoints[i].RFFUbool4 = bool.Parse(RFFUbool4[i].InnerText);
                waypoints[i].RFFUbool5 = bool.Parse(RFFUbool5[i].InnerText);
                waypoints[i].RFFUbool6 = bool.Parse(RFFUbool6[i].InnerText);
                waypoints[i].RFFUbool7 = bool.Parse(RFFUbool7[i].InnerText);
                waypoints[i].RFFUbool8 = bool.Parse(RFFUbool8[i].InnerText);
                waypoints[i].RFFUbool9 = bool.Parse(RFFUbool9[i].InnerText);
                waypoints[i].RFFUbool10 = bool.Parse(RFFUbool10[i].InnerText);

            }
            return waypoints;
        }

        /// <summary>
        /// Reads initial state of the aircraft from the flight plan file.
        /// </summary>
        /// <param name="xmlFP">File name of the flight plan.</param>
        /// <returns></returns>
        public double[] ReadInitialState(XmlDocument xmlFP)
        {
            XmlNodeList ACSx = xmlFP.GetElementsByTagName("x");
            XmlNodeList ACSy = xmlFP.GetElementsByTagName("y");
            XmlNodeList ACSh = xmlFP.GetElementsByTagName("h");
            XmlNodeList ACStas = xmlFP.GetElementsByTagName("tas");
            XmlNodeList ACShdg = xmlFP.GetElementsByTagName("hdg");
            XmlNodeList ACSmass = xmlFP.GetElementsByTagName("mass");
            XmlNodeList ACSthrust = xmlFP.GetElementsByTagName("thrust");
            XmlNodeList ACSbank = xmlFP.GetElementsByTagName("bank");
            XmlNodeList ACSpitch = xmlFP.GetElementsByTagName("pitch");
            XmlNodeList ACSdrag = xmlFP.GetElementsByTagName("drag");
            
            double[] ACState = new double[20];
            double Xpos = System.Convert.ToDouble(ACSx[0].InnerText, CultureInfo.InvariantCulture) * 0.0174532925199433;
            double Ypos = System.Convert.ToDouble(ACSy[0].InnerText, CultureInfo.InvariantCulture) * 0.0174532925199433;
            double[] ENUpos = GT.GeodeticToENU(Xpos, Ypos, 0, RefPointLat, RefPointLon, 0);

            ACState[1] = ENUpos[0];
            ACState[2] = ENUpos[1];
            ACState[3] = System.Convert.ToDouble(ACSh[0].InnerText, CultureInfo.InvariantCulture);
            ACState[4] = System.Convert.ToDouble(ACStas[0].InnerText, CultureInfo.InvariantCulture);
            ACState[5] = System.Convert.ToDouble(ACShdg[0].InnerText, CultureInfo.InvariantCulture);
            ACState[6] = System.Convert.ToDouble(ACSmass[0].InnerText, CultureInfo.InvariantCulture);
            ACState[7] = System.Convert.ToDouble(ACSthrust[0].InnerText, CultureInfo.InvariantCulture);
            ACState[8] = System.Convert.ToDouble(ACSbank[0].InnerText, CultureInfo.InvariantCulture);
            ACState[9] = System.Convert.ToDouble(ACSpitch[0].InnerText, CultureInfo.InvariantCulture);
            ACState[10] = System.Convert.ToDouble(ACSdrag[0].InnerText, CultureInfo.InvariantCulture);

            return ACState;
        }

        /// <summary>
        /// Structure for storing waypoint data when read from the flight plan xml file.
        /// </summary>
        public struct WPT
        {
            public int No; 
            public string name;
            public double x;
            public double y;
            public double z;
            public double t;
            public int flyover;
            public double InstructedTAS;
            public bool IsTASInstructed;
            public double InstructedTrack;
            public bool IsTrackInstructed;
            public double InstructedROCD;
            public bool IsROCDInstructed;
            public double InstructedCAS;
            public bool IsCASInstructed;
            public double InstructedMach;
            public bool IsMachInstructed;
            public double InstructedHeading;
            public bool IsHeadingInstructed;
            public string RFFUstr1;
            public string RFFUstr2;
            public string RFFUstr3;
            public string RFFUstr4;
            public string RFFUstr5;
            public string RFFUstr6;
            public string RFFUstr7;
            public string RFFUstr8;
            public string RFFUstr9;
            public string RFFUstr10;
            public float RFFUfloat1;
            public float RFFUfloat2;
            public float RFFUfloat3;
            public float RFFUfloat4;
            public float RFFUfloat5;
            public float RFFUfloat6;
            public float RFFUfloat7;
            public float RFFUfloat8;
            public float RFFUfloat9;
            public float RFFUfloat10;
            public bool RFFUbool1;
            public bool RFFUbool2;
            public bool RFFUbool3;
            public bool RFFUbool4;
            public bool RFFUbool5;
            public bool RFFUbool6;
            public bool RFFUbool7;
            public bool RFFUbool8;
            public bool RFFUbool9;
            public bool RFFUbool10;

        }

        
   

        /// <summary>
        /// This method returns the desired TAS according to speed schedule as described in Section 4 of Bada Manual 3.10
        /// Returns desired TAS in m/s.
        /// </summary>
        /// <param name="GPFdata">GPF data as loaded by GPFreaderforBada</param>
        /// <param name="APFdata">APF data as loaded by APFreaderforBada</param>
        /// <param name="OPFdata">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="SpdCon">Speed conversion class</param>
        /// <param name="FourD">4D trajectory prediction or not. Boolean</param>
        /// <param name="CLmode">Climb mode: C, L, D</param>
        /// <param name="mass">Current aircraft mass. [kg]</param>
        /// <param name="AtmosphereCon">Atmospheric conditions as calculated by ConditionsAtAlt</param>
        /// <returns>Desired TAS in m/s</returns>
        public double DesiredTAS(GPFReaderforBADA GPFdata, APFReaderforBADA APFdata, OPFReaderforBADA OPFdata,OperationsModel OpsMod, SpeedConversions SpdCon, bool FourD, string CLmode, double mass, AtmCon AtmosphereCon, string ConfigMode)
        {
            double desiredTAS = 0;
            double transalt;
            double V_stall_ref = 0;
            double SpeedMin = 0;
            double Hp = AtmosphereCon.Hp;
            Hp = Hp/0.3048;

            if (FourD)
            {
                //Here goes 4D algo
            }
            else
            {
                switch (CLmode)
                {
                    case "C":
                        V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallTO, mass, OPFdata.MassRef) / 0.5144;
                        transalt = SpdCon.TransitionAltitude(APFdata.M_cl, APFdata.V_cl2 * 0.5144)/0.3048;    
                        switch (OPFdata.EngType)
                        {
                            case "Jet":
                            case "jet":
                            case "j":
                            case "J":
                                double[] VCAS = new double[8];
                                VCAS[7] = APFdata.V_cl2;
                                VCAS[6] = System.Math.Min(APFdata.V_cl1, 250);
                                VCAS[5] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl5, VCAS[6]);
                                VCAS[4] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl4, VCAS[5]);
                                VCAS[3] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl3, VCAS[4]);
                                VCAS[2] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl2, VCAS[3]);
                                VCAS[1] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl1, VCAS[2]);
                                if (Hp < 1500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[1] * 0.5144);
                                if (Hp >= 1500 && Hp < 3000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[2] * 0.5144);
                                if (Hp >= 3000 && Hp < 4000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[3] * 0.5144);
                                if (Hp >= 4000 && Hp < 5000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[4] * 0.5144);
                                if (Hp >= 5000 && Hp < 6000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[5] * 0.5144);
                                if (Hp >= 6000 && Hp < 10000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[6] * 0.5144);
                                if (Hp >= 10000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[7] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_cl, AtmosphereCon.Temperature);
                            break;
                            case "Turboprop":
                            case "turboprop":
                            case "t":
                            case "T":
                            case "Piston":
                            case "piston":
                            case "p":
                            case "P":
                                double[] VCASS = new double[6];
                                VCASS[5] = APFdata.V_cl2;
                                VCASS[4] = System.Math.Min(APFdata.V_cl1, 250);
                                VCASS[3] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl8, VCASS[4]);
                                VCASS[2] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl7, VCASS[3]);
                                VCASS[1] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_cl6, VCASS[2]);
                                if (Hp < 500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[1] * 0.5144);
                                if (Hp >= 500 && Hp < 1000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[2] * 0.5144);
                                if (Hp >= 1000 && Hp < 1500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[3] * 0.5144);
                                if (Hp >= 1500 && Hp < 10000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[4] * 0.5144);
                                if (Hp >= 10000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[5] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_cl, AtmosphereCon.Temperature);
                                break;
                            default:
                                break;
                        }
                        break;
                    case "L":
                        transalt = SpdCon.TransitionAltitude(APFdata.M_cr, APFdata.V_cr2 * 0.5144) / 0.3048;
                        switch (OPFdata.EngType)
                        {
                            case "Jet":
                            case "jet":
                            case "j":
                            case "J":
                                double[] VCAS_ = new double[5];
                                VCAS_[4] = APFdata.V_cr2;
                                VCAS_[3] = System.Math.Min(APFdata.V_cr1, 250);
                                VCAS_[2] = System.Math.Min(APFdata.V_cr1, 220);
                                VCAS_[1] = System.Math.Min(APFdata.V_cr1, 170);
                                if (Hp < 3000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS_[1] * 0.5144);
                                if (Hp >= 3000 && Hp < 6000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS_[2] * 0.5144);
                                if (Hp >= 6000 && Hp < 14000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS_[3] * 0.5144);
                                if (Hp >= 14000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS_[4] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_cr, AtmosphereCon.Temperature);
                                break;
                            case "Turboprop":
                            case "turboprop":
                            case "t":
                            case "T":
                            case "Piston":
                            case "piston":
                            case "p":
                            case "P":
                                double[] VCASa = new double[5];
                                VCASa[4] = APFdata.V_cr2;
                                VCASa[3] = System.Math.Min(APFdata.V_cr1, 250);
                                VCASa[2] = System.Math.Min(APFdata.V_cr1, 180);
                                VCASa[1] = System.Math.Min(APFdata.V_cr1, 150);
                                if (Hp < 3000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASa[1] * 0.5144);
                                if (Hp >= 3000 && Hp < 6000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASa[2] * 0.5144);
                                if (Hp >= 6000 && Hp < 10000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASa[3] * 0.5144);
                                if (Hp >= 10000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASa[4] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_cr, AtmosphereCon.Temperature);
                                break;
                            default:
                                break;
                        }
                        break;
                   case "D":
                        V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallLD, mass, OPFdata.MassRef) / 0.5144;
                        transalt = SpdCon.TransitionAltitude(APFdata.M_des, APFdata.V_des2 * 0.5144) / 0.3048;
                        switch (OPFdata.EngType)
                        {
                            case "Jet":
                            case "jet":
                            case "j":
                            case "J":
                                double[] VCAS = new double[8];
                                VCAS[7] = APFdata.V_des2;
                                VCAS[6] = System.Math.Min(APFdata.V_des1, 250);
                                VCAS[5] = System.Math.Min(APFdata.V_des1, 220);
                                VCAS[4] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des4, VCAS[5]);
                                VCAS[3] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des3, VCAS[4]);
                                VCAS[2] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des2, VCAS[3]);
                                VCAS[1] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des1, VCAS[2]);
                                if (Hp < 1000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[1] * 0.5144);
                                if (Hp >= 1000 && Hp < 1500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[2] * 0.5144);
                                if (Hp >= 1500 && Hp < 2000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[3] * 0.5144);
                                if (Hp >= 2000 && Hp < 3000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[4] * 0.5144);
                                if (Hp >= 3000 && Hp < 6000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[5] * 0.5144);
                                if (Hp >= 6000 && Hp < 10000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[6] * 0.5144);
                                if (Hp >= 10000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCAS[7] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_des, AtmosphereCon.Temperature);
                                break;
                            case "Turboprop":
                            case "turboprop":
                            case "t":
                            case "T":
                            case "Piston":
                            case "piston":
                            case "p":
                            case "P":
                                double[] VCASS = new double[6];
                                VCASS[5] = APFdata.V_des2;
                                VCASS[4] = APFdata.V_des1;
                                VCASS[3] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des7, VCASS[4]);
                                VCASS[2] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des6, VCASS[3]);
                                VCASS[1] = System.Math.Min(GPFdata.C_vmin * V_stall_ref + GPFdata.V_des5, VCASS[2]);
                                if (Hp < 500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[1] * 0.5144);
                                if (Hp >= 500 && Hp < 1000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[2] * 0.5144);
                                if (Hp >= 1000 && Hp < 1500) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[3] * 0.5144);
                                if (Hp >= 1500 && Hp < 10000) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[4] * 0.5144);
                                if (Hp >= 10000 && Hp < transalt) desiredTAS = SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, VCASS[5] * 0.5144);
                                if (Hp >= transalt) desiredTAS = SpdCon.MachtoTAS(APFdata.M_des, AtmosphereCon.Temperature);
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
            }

            //Check for minimum and maximum allowed speeds.
            if (ConfigMode == "TO")
            {
                V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallTO, mass, OPFdata.MassRef);
                SpeedMin = OpsMod.MinimumSpeed(V_stall_ref, GPFdata.C_vminto);
            }
            else if (ConfigMode == "IC")
            {
                V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallIC, mass, OPFdata.MassRef);
                SpeedMin = OpsMod.MinimumSpeed(V_stall_ref, GPFdata.C_vmin);
            }
            else if (ConfigMode == "CL")
            {
                V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallCR, mass, OPFdata.MassRef);
                SpeedMin = OpsMod.MinimumSpeed(V_stall_ref, GPFdata.C_vmin);
            }
            else if (ConfigMode == "APP")
            {
                V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallAP, mass, OPFdata.MassRef);
                SpeedMin = OpsMod.MinimumSpeed(V_stall_ref, GPFdata.C_vmin);
            }
            else if (ConfigMode == "LDG")
            {
                V_stall_ref = OpsMod.SpeedforMass(OPFdata.VstallLD, mass, OPFdata.MassRef);
                SpeedMin = OpsMod.MinimumSpeed(V_stall_ref, GPFdata.C_vmin);
            }

            if (AtmosphereCon.Hp > (15000 * 0.3048) && OPFdata.EngType == "Jet") //Low speed buffeting limit below 15000ft for jet aircraft.
            {
                double BuffetingLimitMach = OpsMod.JetLowSpeedBuffeting(OPFdata.BuffGradK, OPFdata.C_Lbo, mass * g0, OPFdata.WingArea, AtmosphereCon.Pressure);
                if (SpeedMin < SpdCon.MachtoTAS(BuffetingLimitMach, AtmosphereCon.Temperature)) SpeedMin = SpdCon.MachtoTAS(BuffetingLimitMach, AtmosphereCon.Temperature);
            }

            if (desiredTAS < SpeedMin) desiredTAS = SpeedMin;

            if (desiredTAS > SpdCon.CAStoTAS(AtmosphereCon.Pressure, AtmosphereCon.Density, OPFdata.V_MaxOp)) desiredTAS = OPFdata.V_MaxOp;

            if (desiredTAS > SpdCon.MachtoTAS(OPFdata.Ma_MaxOp, AtmosphereCon.Temperature)) desiredTAS = SpdCon.MachtoTAS(OPFdata.Ma_MaxOp, AtmosphereCon.Temperature);

            return desiredTAS;
        }

        /// <summary>
        /// Determines the acceleration mode which can be (A)ccelerate, (C)onstant, and (D)eccelerate.
        /// Prevents instantaneous switching from acceleration mode to decceleration and vice versa.
        /// </summary>
        /// <param name="TAS">True airspeed. [m/s]</param>
        /// <param name="DesTAS">Desired true airspeed. [m/s]</param>
        /// <param name="ACCmode">Current acceleration mode.</param>
        /// <returns>Acceleration mode as: (A)ccelerate, (C)onstant, and (D)eccelerate. String. </returns>
        public string ACCModeSet(double TAS, double DesTAS, string ACCmode)
        {
            string ACmode;
            if ( TAS < (DesTAS - Vtol)) //Current TAS is lower than desired Tas
            {
                if (ACCmode == "C" || ACCmode == "A") //prevents instantly switching from decceleration to acceleration
                {
                    ACmode = "A";
                }
                else
                {
                    ACmode = "C";
                }
            }
            else if (TAS > (DesTAS + Vtol))
            {
                if (ACCmode == "C" || ACCmode == "D")
                {
                    ACmode = "D";
                }
                else
                {
                    ACmode = "C";
                }
            }
            else
            {
                ACmode = "C";
            }

            return ACmode;
        }

        /// <summary>
        /// Determines the climb mode which can be (C)limb, (L)evel, and (D)escent.
        /// Prevents instantaneous switching from climb mode to descent and vice versa.
        /// </summary>
        /// <param name="h">Current geodetic altitude. [m]</param>
        /// <param name="h_desired">Desired geodetic altitude. [m]</param>
        /// <param name="CLmode">Current climb mode.</param>
        /// <returns>Climb mode which can be: (C)limb, (L)evel, and (D)escent.</returns>
        public string CLModeSet(double h, double h_desired, string CLmode)
        {
            string Cmode;
            if (h < (h_desired - Htol)) //Current altitude is lower than desired altitude
            {
                if (CLmode == "C" || CLmode == "L") //prevents instantly switching from climb to descent
                {
                    Cmode = "C";
                }
                else
                {
                    Cmode = "L";
                }
            }
            else if (h > (h_desired + Htol))
            {
                if (CLmode == "D" || CLmode == "L")
                {
                    Cmode = "D";
                }
                else
                {
                    Cmode = "L";
                }
            }
            else
            {
                Cmode = "L";
            }

            return Cmode;
        }

        /// <summary>
        /// Determines the aircraft configuration mode which can be (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G).
        /// Reflects standards from p. 19. of BADA Manual 3.10 (section 3.5)
        /// </summary>
        /// <param name="GPFData">GPF data as loaded by GPFreaderforBada</param>
        /// <param name="OPFData">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="Hp">Geopotential pressure altitude. [m]</param>
        /// <param name="ElevData">Elevation data. NOT YET IMPLEMENTED! See comment in code.</param>
        /// <param name="CAS">Calibrated airspeed. [m/s]</param>
        /// <param name="CLmode">Climb mode: C, L, D</param>
        /// <returns>Returns the a/c configuration mode.</returns>
        public string ConfigModeSet(GPFReaderforBADA GPFData, OPFReaderforBADA OPFData, double Hp, double[] ElevData, double CAS, string CLmode)
        {
            string ConfigMode = "ERR";
            double VminTO = GPFData.C_vminto * OPFData.VstallTO;
            double VminIC = GPFData.C_vmin * OPFData.VstallIC;
            double VminCR = GPFData.C_vmin * OPFData.VstallCR;
            double VminAP = GPFData.C_vmin * OPFData.VstallAP;
            double VminLD = GPFData.C_vmin * OPFData.VstallLD;

            double Hp_AGL = Hp - 0; //Instead of '0' there should go a value from the elevation data.

            if (CLmode == "C")
            {
                if (Hp_AGL < (GPFData.H_maxto * 0.3048))
                {
                    ConfigMode = "TO";
                }
                else if (Hp_AGL >= (GPFData.H_maxto * 0.3048) && Hp_AGL < (GPFData.H_maxic * 0.3048))
                {
                    ConfigMode = "IC";
                }
                else
                {
                    ConfigMode = "CL";
                }
            }
            else if (CLmode == "L")
            {
                ConfigMode = "CL";
            }
            else
            {
                if (Hp_AGL < (GPFData.H_maxld * 0.3048) && CAS < (VminAP +10))
                {
                    ConfigMode = "LDG";
                }
                else if (Hp_AGL < (GPFData.H_maxapp * 0.3048) && Hp_AGL > (GPFData.H_maxld * 0.3048) && CAS < (VminCR + 10))
                {
                    ConfigMode = "APP";
                }
                else if (Hp_AGL < (GPFData.H_maxld * 0.3048) && CAS < (VminCR + 10) && CAS >= (VminAP + 10))
                {
                    ConfigMode = "APP";
                }
                else if (Hp_AGL > (GPFData.H_maxapp * 0.3048))
                {
                    ConfigMode = "CL";
                }
                else if (Hp_AGL < (GPFData.H_maxapp * 0.3048) && CAS >= (VminCR + 10))
                {
                    ConfigMode = "CL";
                }
            }

            return ConfigMode;

        }

        /// <summary>
        /// Determines the required thrust. Returns thrust in Newtons.
        /// </summary>
        /// <param name="GPFdata">GPF data as loaded by GPFreaderforBada</param>
        /// <param name="OpsMod">Operations model from the class library.</param>
        /// <param name="OPFdata">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="ACState">Current aircraft state array.</param>
        /// <param name="AtmCons">Atmospheric conditions as calculated by ConditionsAtAlt</param>
        /// <param name="ClMode">Climb mode: C, L, D</param>
        /// <param name="DesTAS">Desired TAS. [m/s]</param>
        /// <param name="AccMode">Acceleration mode: A, C, D</param>
        /// <param name="Meteo">Meteo data {temp, pressure, windx, wy, wz}</param>
        /// <param name="ConfigMode">Aircraft configuration mode which can be (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)</param>
        /// <returns>Thrust in Newtons.</returns>
        public double ThrustSet(GPFReaderforBADA GPFdata, OperationsModel OpsMod, OPFReaderforBADA OPFdata, Array ACState, AtmCon AtmCons, string ClMode, double DesTAS, string AccMode, double[] Meteo, string ConfigMode, WPT[] waypoints, int WPTi, double ESF)
        {
            double Thrust=-999999;
            double CurrentSpd = (double)ACState.GetValue(4);

            double TmaxCl = OpsMod.ThrustMaxClimb(AtmCons.Hp, Meteo[0] - 288.15, OPFdata.C_Tc1, OPFdata.C_Tc2, OPFdata.C_Tc3, OPFdata.C_Tc4, OPFdata.C_Tc5, (double)ACState.GetValue(4), OPFdata.EngType);
            double Tdes = OpsMod.ThrustInDescent(AtmCons.Hp / 0.3048, OPFdata.Hpdes, TmaxCl, OPFdata.C_Tdeslow, OPFdata.C_Tdeshigh, OPFdata.C_Tdesapp, OPFdata.C_Tdesld, ConfigMode);
            double TmaxCruise = OpsMod.ThrustMaxCruise(TmaxCl, GPFdata.C_Tcr);
            
            //NOT HERE! Treduced is to be applied in TEM formula according to eq. 3.8-2 in Bada manual 3.10
            double Hmax = OpsMod.MaximumAltitude(OPFdata.Alt_MaxOp,OPFdata.Alt_Max_at_MTOW,OPFdata.TempGrad, OPFdata.WeightGrad, Meteo[0]-288.15, OPFdata.C_Tc4, OPFdata.MassMax, (double)ACState.GetValue(6));
            double CTred = OpsMod.ReducedClimbPowerCoeff(Hmax, AtmCons.Hp, OPFdata.MassMax, OPFdata.MassMin, (double)ACState.GetValue(6), OPFdata.EngType);

            if (ClMode == "L" && AccMode=="C") //Level and Constant
            {
                double ThrForSpeed = ((double)ACState.GetValue(10) * OPFdata.WingArea * AtmCons.Density * DesTAS * DesTAS) / 2 + g0 * Math.Sin((double)ACState.GetValue(9)) / ((double)ACState.GetValue(6));
                Thrust = ThrForSpeed;
                if (ThrForSpeed > TmaxCruise) Thrust = TmaxCruise;
            }
            else if (ClMode == "L" && AccMode == "A") //Level and Accelerating
            {
                double ThrForMaxAccel = GPFdata.a_lmax * 0.3048 * (double)ACState.GetValue(6) + ((double)ACState.GetValue(10) * OPFdata.WingArea * AtmCons.Density * (double)ACState.GetValue(4) * (double)ACState.GetValue(4)) / 2 + g0 * Math.Sin((double)ACState.GetValue(9)) * (double)ACState.GetValue(6);
                Thrust = ThrForMaxAccel;
                if (ThrForMaxAccel > TmaxCruise) Thrust = TmaxCruise;
            }
            else if (ClMode == "L" && AccMode == "D") //Level and Decelerating
            {
                double ThrForMaxDecel = -GPFdata.a_lmax * 0.3048 * (double)ACState.GetValue(6) + ((double)ACState.GetValue(10) * OPFdata.WingArea * AtmCons.Density * (double)ACState.GetValue(4) * (double)ACState.GetValue(4)) / 2 + g0 * Math.Sin((double)ACState.GetValue(9)) * (double)ACState.GetValue(6);
                Thrust = ThrForMaxDecel;
                if (ThrForMaxDecel > TmaxCruise) Thrust = TmaxCruise;
            }
            else if (ClMode == "C") //Climbing
            {
                if (!waypoints[WPTi].IsROCDInstructed)//if AC follows default climb/descent schedule
                {
                    if ((double)ACState.GetValue(3) < (Hmax * 0.8 * 0.3048))
                    {
                        Thrust = TmaxCl * CTred;
                    }
                    else { Thrust = TmaxCl; }
                }
                else //If ROCD is given by ATC
                {
                    double Drag = OpsMod.DragForce((double)ACState.GetValue(10),CurrentSpd ,AtmCons.Density,OPFdata.WingArea);
                    Thrust = tem.VariableThrust(waypoints[WPTi].InstructedROCD,CurrentSpd,Drag,(double)ACState.GetValue(6),ESF,AtmCons.Temperature,0);
                }
                if (Thrust > TmaxCl) Thrust = TmaxCl;
            }
            else if (ClMode == "D") //Descent
            {
                if (!waypoints[WPTi].IsROCDInstructed) //if AC follows default climb/descent schedule
                {
                    Thrust = Tdes;
                }
                else //If ROCD is given by ATC
                {
                    double Drag = OpsMod.DragForce((double)ACState.GetValue(10), CurrentSpd, AtmCons.Density, OPFdata.WingArea);
                    Thrust = tem.VariableThrust(waypoints[WPTi].InstructedROCD, CurrentSpd, Drag, (double)ACState.GetValue(6), ESF, AtmCons.Temperature, 0);
                }
            }
            if (Thrust < 0) Thrust = 0;
            return Thrust;
        }

        /// <summary>
        /// Determines the drag coefficient (CD) based on the aircraft configuration and lift coefficient.
        /// </summary>
        /// <param name="OPFdata">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="OpsMod">Operations model from the class library.</param>
        /// <param name="ConfMode">Configuration mode as set by ConfigModeSet.</param>
        /// <param name="LiftCoeff">Lift coefficient. [dimensionless]</param>
        /// <returns>Drag coefficient. [dimensionless]</returns>
        public double DragCoefficient(OPFReaderforBADA OPFdata, OperationsModel OpsMod, string ConfMode, double LiftCoeff)
        {
            double CD;

            if (ConfMode == "APP" && OPFdata.C_D0AP != 0)
            {
                CD = OpsMod.DragCoefficient(LiftCoeff, OPFdata.C_D0AP, OPFdata.C_D2AP, 0);
            }
            else if (ConfMode == "LDG" && OPFdata.C_D0LD != 0)
            {
                CD = OpsMod.DragCoefficient(LiftCoeff, OPFdata.C_D0LD, OPFdata.C_D2LD, OPFdata.C_D0dLDG);
            }
            else
            {
                CD = OpsMod.DragCoefficient(LiftCoeff, OPFdata.C_D0CR, OPFdata.C_D2CR, 0);
            }
            return CD;
        }

        /// <summary>
        /// Determines the required pitch angle.
        /// </summary>
        /// <param name="OPFdata">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="GPFdata">GPF data as loaded by GPFreaderforBada</param>
        /// <param name="ACState">Current aircraft state array.</param>
        /// <param name="DesiredAlt">Desired altitude. Altitude of the next waypoint.</param>
        /// <param name="ESF">Energy share factor</param>
        /// <param name="AtmCons">Atmospheric conditions as calculated by ConditionsAtAlt</param>
        /// <returns>Pitch angle in radians.</returns>
        public double PitchSet(OPFReaderforBADA OPFdata, GPFReaderforBADA GPFdata, Array ACState, double DesiredAlt, double ESF, AtmCon AtmCons)
        {
            double CurrentAlt = (double)ACState.GetValue(3); //Renaming these to make code more readable
            double CurrentSpd = (double)ACState.GetValue(4);
            double CurrentPitch = (double)ACState.GetValue(9);
            double Thr = (double)ACState.GetValue(7);
            double CD = (double)ACState.GetValue(10);
            double Mass = (double)ACState.GetValue(6);

            double NewPitch;
            double dPitchMax = GPFdata.a_nmax * 0.3048 / CurrentSpd ; //Maximum allowed pitch change rad/sec

            double AltToLevel = 0; //Required altitude change for aircraft to change attitude from current to level
            
            double NSteps = CurrentPitch / dPitchMax; //number of steps required to change from current pitch to level
            NSteps = Math.Abs(Math.Round(NSteps));
            
            double dAlt =Math.Abs(DesiredAlt - CurrentAlt); //altitude difference
            
            if (NSteps == 0)
            {
                AltToLevel = Htol;
            }
            else
            {
                for (int i = 0; i <= (int)NSteps; i++)
                {
                    AltToLevel = AltToLevel + CurrentSpd * Math.Sin(Math.Abs(Math.Abs(CurrentPitch) - i * dPitchMax)); //sum of all altitude changes
                }
            }

            double DesiredPitch = Math.Asin((Thr - (CD * OPFdata.WingArea * AtmCons.Density * CurrentSpd * CurrentSpd) / 2) * ESF / (g0 * Mass)); //Ideal pitch for climb or descent

            if (CurrentAlt < (DesiredAlt-Htol)) //AC is below desired alt
            {
                if (dAlt <= AltToLevel) //AC should start turning horizontal
                {
                    if (CurrentPitch >= 0)
                    {
                        NewPitch = CurrentPitch - dPitchMax;
                    }
                    else
                    {
                        NewPitch = CurrentPitch + dPitchMax;
                    }
                }
                else //AC should set pitch for climb
                {
                    if (CurrentPitch < (DesiredPitch-dPitchMax))
                    {
                        NewPitch = CurrentPitch + dPitchMax;
                    }
                    else if (CurrentPitch > (DesiredPitch+dPitchMax))
                    {
                        NewPitch = CurrentPitch - dPitchMax;
                    }
                    else
                    {
                        NewPitch = DesiredPitch;
                    }
                }
            }
            else if (CurrentAlt > (DesiredAlt + Htol)) //AC is above desired alt
            {
                if (dAlt <= AltToLevel) //AC should start turning horizontal
                {
                    if (CurrentPitch <= 0)
                    {
                        NewPitch = CurrentPitch + dPitchMax;
                    }
                    else
                    {
                        NewPitch = CurrentPitch - dPitchMax;
                    }
                }
                else //AC should set pitch for descent
                {
                    if (CurrentPitch < (DesiredPitch - dPitchMax))
                    {
                        NewPitch = CurrentPitch + dPitchMax;
                    }
                    else if (CurrentPitch > (DesiredPitch + dPitchMax))
                    {
                        NewPitch = CurrentPitch - dPitchMax;
                    }
                    else
                    {
                        NewPitch = DesiredPitch;
                    }
                }
            }
            else //AC is at desired altitude
            {
                if (CurrentPitch < -dPitchMax)
                {
                    NewPitch = CurrentPitch + dPitchMax;
                }
                else if (CurrentPitch > dPitchMax)
                {
                    NewPitch = CurrentPitch - dPitchMax;
                }
                else
                {
                    NewPitch = 0;
                }
            }
            

            return NewPitch;
        }

        /// <summary>
        /// Bank angle controller. Returns new bank angle in radians.
        /// </summary>
        /// <param name="OPFdata">OPF data as loaded by OPFreaderforBada</param>
        /// <param name="GPFdata">GPF data as loaded by GPFreaderforBada</param>
        /// <param name="ACState">Current aircraft state array.</param>
        /// <param name="AtmCons">Atmospheric conditions as calculated by ConditionsAtAlt</param>
        /// <param name="waypoints">Waypoints as loaded in the WPT struct</param>
        /// <param name="WPTi">Current waypoint index</param>
        /// <param name="ConfMode">Configuration mode as set by ConfigModeSet.</param>
        /// <param name="Holding">Holding mode.</param>
        /// <param name="Meteo">Meteo data {temp, pressure, windx, wy, wz}</param>
        /// <returns>New bank angle in radians.</returns>
        public double BankSet(OPFReaderforBADA OPFdata, GPFReaderforBADA GPFdata, Array ACState, AtmCon AtmCons, WPT[] waypoints, int WPTi, string ConfMode, bool Holding, double[] Meteo)
        {
            /*
             *This is a bank angle controller that assumes that an aircraft can be at a significant distance from the desired track.
             *First, cross-track error is calculated and from it a required heading for intercepting the desired track is calculated.
             *Then, bank angle is adjusted in such way that the aircraft is heading in the required direction (i.e. intercept heading).
             *Intercept heading is initially perpendicular to the track, but as aircraft closes in on the track it reduces gradually.
             *Final intercept heading is equal to the desired heading which is equal to track corrected for wind correction angle.
             *Crude numerical integration is employed to calculate the lead angle at which the aircraft needs to start rolling out
             *of the turn in order to exit the turn in the right heading. Undoubtedly there is a lot of room for improvement in this regard
             *and in the controller as a whole.
             */
            
            double Track; //Track from previous waypoint to the next.
            double DirectTo; //Track direct from ac position to next waypoint
            double CurrentX = (double)ACState.GetValue(1); //renamed for readability
            double CurrentY = (double)ACState.GetValue(2);
            double CurrentSpd = (double)ACState.GetValue(4);
            double CurrentHdg = (double)ACState.GetValue(5);
            double CurrentBank = (double)ACState.GetValue(8);
            double CTE; //Cross-track error
            double BankMax; //Maximum allowed bank angle

            if (waypoints[WPTi].IsTrackInstructed) //if atc gave track instruction
            {
                Track = waypoints[WPTi].InstructedTrack;
            }
            else
            {
                Track = Math.Atan2(waypoints[WPTi].y - waypoints[WPTi - 1].y, waypoints[WPTi].x - waypoints[WPTi - 1].x);
            }
            DirectTo = Math.Atan2(waypoints[WPTi].y - CurrentY, waypoints[WPTi].x - CurrentX);
            CTE = Math.Sqrt(Math.Pow(waypoints[WPTi].y - CurrentY, 2) + Math.Pow(waypoints[WPTi].x - CurrentX, 2))*Math.Sin(Track-DirectTo);

            if (ConfMode == "TO")
            {
                BankMax = GPFdata.phi_nomcivto * Math.PI/180;
            }
            else
            {
                if (Holding)
                {
                    BankMax = GPFdata.phi_maxcivhold * Math.PI / 180;
                }
                else { BankMax = GPFdata.phi_nomciv * Math.PI / 180; }
            }

            double TurnRadius = CurrentSpd * CurrentSpd / (g0 * Math.Tan(BankMax));
            double RelativeDist = CTE / TurnRadius;

            double WindDir = Math.Atan2(Meteo[3], Meteo[2]);
            double WindSpd = Math.Sqrt(Meteo[2] * Meteo[2] + Meteo[3] * Meteo[3]);
            double WCA = Math.Asin(Math.Sin(Track - WindDir) * WindSpd / CurrentSpd);
            double DesiredHdg = 0;
            if (waypoints[WPTi].IsHeadingInstructed) //if atc gave heading instructions
            {
                DesiredHdg = waypoints[WPTi].InstructedHeading;
            }
            else
            {
                DesiredHdg = Track + WCA;
            }
            double InterceptHdg; //Heading that will intercept the track corrected for wind (DesiredHdg).

            if (RelativeDist > 0.01)
            {
                InterceptHdg = DesiredHdg - Math.Min(45* Math.Abs(RelativeDist), 90)*Math.PI/180;
            }
            else if (RelativeDist < -0.01)
            {
                InterceptHdg = DesiredHdg + Math.Min(45 * Math.Abs(RelativeDist), 90) * Math.PI / 180;
            }
            else
            {
                InterceptHdg = DesiredHdg;
            }
            if (waypoints[WPTi].IsTrackInstructed || waypoints[WPTi].IsHeadingInstructed)
            {
                InterceptHdg = DesiredHdg; //if atc gave track/heading instrucions
            }
            else
            {
                InterceptHdg = DirectTo + WCA; //THIS LINE makes the aircraft fly straight from current position towards next point.
                //It makes the previous calculation of the intercepthdg obsolete.
                //By removing this line the aircraft will fly along the reference line from one waypoint to the other. 
            }
            double NSteps = CurrentBank / 0.034906585; //number of steps required to change from current bank to 0° (step is 2°/s)
            NSteps = Math.Abs(Math.Round(NSteps));

            double sum = 0;
            double LeadHdg; //Lead heading is actually heading difference at which ac needs to start rolling out of the turn in order to roll out at desired hdg.

            if (NSteps == 0)
            {
                LeadHdg = 0;
            }
            else
            {
                if (CurrentBank > 0)
                {
                    for (int i = 0; i <= (int)NSteps; i++)
                    {
                        sum = sum + Math.Tan(CurrentBank - 0.034906585 * i); //sum of tans
                    }
                }
                else
                {
                    for (int i = 0; i <= (int)NSteps; i++)
                    {
                        sum = sum + Math.Tan(CurrentBank + 0.034906585 * i); //sum of tans
                    }
                }

                LeadHdg = g0 * sum / CurrentSpd;
            }

            double HdgDiff = InterceptHdg - CurrentHdg;

            if (Math.Abs(HdgDiff) > Math.PI*2) //2PI or not 2PI?
            {
                HdgDiff =Math.IEEERemainder(HdgDiff, Math.PI*2); //bounding the value of HdgDiff to +/-Pi
            }

            bool DirectionLeft;
            if (Math.Sin(HdgDiff) > 0)
            {
                DirectionLeft = true;
            }
            else { DirectionLeft = false; }
            
            
            double NewBank = 0;
            if (DirectionLeft && CurrentBank < 0) //AC is banking right and it should turn left
            {
                NewBank = CurrentBank + 0.034906585; //0.034906585 is 2° in radians (2°/s is selected maximum bank angle change)
            }
            else if (!DirectionLeft && CurrentBank > 0) //AC is banking left and it should turn right
            {
                NewBank = CurrentBank - 0.034906585;
            }
            else
            {
                if (DirectionLeft && HdgDiff > LeadHdg)
                {
                    NewBank = CurrentBank + 0.034906585;
                }
                else if (DirectionLeft && HdgDiff <= LeadHdg)
                {
                    if (HdgDiff < 0)
                    {
                        NewBank = CurrentBank + 0.034906585;
                    }
                    else
                    {
                        NewBank = CurrentBank - 0.034906585;
                    }
                }
                else if (!DirectionLeft && HdgDiff < LeadHdg || !DirectionLeft && HdgDiff > Math.PI)
                {
                    NewBank = CurrentBank - 0.034906585;
                }
                else if (!DirectionLeft && HdgDiff >= LeadHdg)
                {
                    NewBank = CurrentBank + 0.034906585;
                }

            }

            if (Math.Abs(NewBank) > BankMax)
            {
                if (NewBank > 0)
                {
                    NewBank = NewBank - 0.034906585;
                }
                else
                {
                    NewBank = NewBank + 0.034906585;
                }
            }
            
            return NewBank;
        }

    }

}
