import '../styles/globals.css'
import { FirebaseProvider } from '../src/firebase'

function MyApp({ Component, pageProps }) {
  return (
    <FirebaseProvider>
      <Component {...pageProps} />
    </FirebaseProvider>
  )
}

export default MyApp
