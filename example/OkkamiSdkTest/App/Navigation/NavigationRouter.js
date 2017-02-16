// @flow

import React, { Component } from 'react'
import { Scene, Router } from 'react-native-router-flux'
import Styles from './Styles/NavigationContainerStyle'
import NavigationDrawer from './NavigationDrawer'
import NavItems from './NavItems'
import CustomNavBar from '../Navigation/CustomNavBar'

// screens identified by the router
import PresentationScreen from '../Containers/PresentationScreen'
import AllComponentsScreen from '../Containers/AllComponentsScreen'
import UsageExamplesScreen from '../Containers/UsageExamplesScreen'
import LoginScreen from '../Containers/LoginScreen'
import ListviewExample from '../Containers/ListviewExample'
import ListviewGridExample from '../Containers/ListviewGridExample'
import ListviewSectionsExample from '../Containers/ListviewSectionsExample'
import ListviewSearchingExample from '../Containers/ListviewSearchingExample'
import MapviewExample from '../Containers/MapviewExample'
import APITestingScreen from '../Containers/APITestingScreen'
import ThemeScreen from '../Containers/ThemeScreen'
import DeviceInfoScreen from '../Containers/DeviceInfoScreen'
import PromotionScreen from '../Containers/PromotionScreen'

// add
import SignUpScreen from '../Containers/SignUpScreen'
import Splash from '../Containers/Splash'
import SignInScreen from '../Containers/SignInScreen'
import SocialConnectionScreen from '../Containers/SocialConnectionScreen'
import SocialConnectionSignInScreen from '../Containers/SocialConnectionSignInScreen'
import RoomControlsScreen from '../Containers/RoomControlsScreen'
import UploadPictureScreen from '../Containers/UploadPictureScreen'
import OpenWebView from '../Containers/OpenWebView'
import LandingScreen from '../Containers/LandingScreen'
import FacebookLoginScreen from '../Containers/FacebookLoginScreen'
import EditProfileScreen from '../Containers/EditProfileScreen'


/* **************************
* Documentation: https://github.com/aksonov/react-native-router-flux
***************************/

class NavigationRouter extends Component {
  render () {
    return (
      <Router>
        <Scene key='drawer' component={NavigationDrawer} open={false}>
          <Scene key='drawerChildrenWrapper' navigationBarStyle={Styles.navBar} titleStyle={Styles.title} leftButtonIconStyle={Styles.leftButton} rightButtonTextStyle={Styles.rightButton}>
            <Scene key='presentationScreen' component={PresentationScreen} title='Ignite' renderLeftButton={NavItems.hamburgerButton} />
            <Scene key='componentExamples' component={AllComponentsScreen} title='Components' />
            <Scene key='usageExamples' component={UsageExamplesScreen} title='Usage' rightTitle='Example' onRight={() => window.alert('Example Pressed')} />
            <Scene key='login' component={LoginScreen} title='Login' hideNavBar />
            <Scene key='listviewExample' component={ListviewExample} title='Listview Example' />
            <Scene key='listviewGridExample' component={ListviewGridExample} title='Listview Grid' />
            <Scene key='listviewSectionsExample' component={ListviewSectionsExample} title='Listview Sections' />
            <Scene key='listviewSearchingExample' component={ListviewSearchingExample} title='Listview Searching' navBar={CustomNavBar} />
            <Scene key='mapviewExample' component={MapviewExample} title='Mapview Example' />
            <Scene key='apiTesting' component={APITestingScreen} title='API Testing' />
            <Scene key='theme' component={ThemeScreen} title='Theme' />

            {/* Custom navigation bar example */}
            <Scene key='deviceInfo' component={DeviceInfoScreen} title='Device Info' />

            <Scene initial key='splashScreen' component={Splash} title='Components'/>
            <Scene key="promotionScreen" component={PromotionScreen} title='Promotion'/>
            <Scene key="signUpScreen" component={SignUpScreen} title='Sign Up'/>
            <Scene key="signInScreen" component={SignInScreen} title='Sign In'/>
            <Scene key="socialConnectionScreen" component={SocialConnectionScreen} title='Social Connection'/>
            <Scene key="socialConnectionSignInScreen" component={SocialConnectionSignInScreen} title='Social Connection'/>
            <Scene key="roomControlsScreen" component={RoomControlsScreen} title='Room Controls'/>
            <Scene key="uploadPictureScreen" component={UploadPictureScreen} title='Upload Picutre'/>
            <Scene key="openWebView" component={OpenWebView} title='Web'/>
            <Scene key="landingScreen" component={LandingScreen} title='Landing Screen'/>
            <Scene key="facebookLoginScreen" component={FacebookLoginScreen} title='Facebook'/>
            <Scene key="editProfileScreen" component={EditProfileScreen} title='Edit Profile'/>

          </Scene>
        </Scene>
      </Router>
    )
  }
}

export default NavigationRouter
