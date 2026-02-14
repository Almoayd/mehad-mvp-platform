import React, { createContext, useContext, useEffect, useState } from 'react'
import { initializeApp } from 'firebase/app'
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth'
import { getFirestore, collection, doc, setDoc, getDoc, onSnapshot, addDoc, query, where, orderBy } from 'firebase/firestore'

// TODO: replace with your Firebase config (or leave placeholders to run without Firebase)
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "",
  appId: ""
}

const isConfigured = firebaseConfig.apiKey && !firebaseConfig.apiKey.includes('YOUR') && firebaseConfig.projectId && !firebaseConfig.projectId.includes('YOUR')

let app = null
let auth = null
let db = null
if (isConfigured) {
  app = initializeApp(firebaseConfig)
  auth = getAuth(app)
  db = getFirestore(app)
} else {
  console.warn('Firebase not configured — running in offline/no-backend mode')
}

const FirebaseContext = createContext(null)

export function FirebaseProvider({ children }){
  const [user, setUser] = useState(null)

  useEffect(()=>{
    // basic listener - Firestore auth listener would go here if configured
    return () => {}
  },[])

  // Auth helpers
  const signUp = async ({ name, email, password, role, description }) => {
    if (!isConfigured) {
      console.warn('signUp: Firebase not configured')
      return false
    }
    try{
      const cred = await createUserWithEmailAndPassword(auth, email, password)
      const uid = cred.user.uid
      await setDoc(doc(db, 'users', uid), { email, name, role, description, rating: 4.5 })
      setUser({ uid, email, name, role, description })
      return true
    }catch(e){
      console.error(e)
      return false
    }
  }

  const signIn = async (email, password) => {
    if (!isConfigured) {
      console.warn('signIn: Firebase not configured')
      return false
    }
    try{
      const cred = await signInWithEmailAndPassword(auth, email, password)
      const udoc = await getDoc(doc(db, 'users', cred.user.uid))
      setUser(udoc.exists() ? { uid: udoc.id, ...udoc.data() } : { uid: cred.user.uid, email })
      return true
    }catch(e){
      console.error(e)
      return false
    }
  }

  // Projects & offers
  const createProject = async ({ type, location, minBudget, maxBudget, description }) => {
    if (!isConfigured) {
      console.warn('createProject: Firebase not configured')
      return null
    }
    try{
      const p = await addDoc(collection(db, 'projects'), { type, location, minBudget, maxBudget, description, status: 'Pending', createdAt: new Date() })
      return p.id
    }catch(e){
      console.error(e)
      return null
    }
  }

  const listProjects = (onChange) => {
    if (!isConfigured) {
      onChange([])
      return () => {}
    }
    const q = query(collection(db, 'projects'), orderBy('createdAt','desc'))
    const unsub = onSnapshot(q, snap => onChange(snap.docs.map(d=> ({ id: d.id, ...d.data() }))))
    return unsub
  }

  const listMyProjectsWithOffers = (onChange) => {
    if (!isConfigured) {
      onChange([])
      return () => {}
    }
    // simple placeholder: client should query projects by clientId
    const q = query(collection(db, 'projects'), orderBy('createdAt','desc'))
    const unsub = onSnapshot(q, snap => onChange(snap.docs.map(d=> ({ id: d.id, ...d.data(), offers: [] }))))
    return unsub
  }

  const streamProjectMessages = (projectId, onChange) => {
    if (!isConfigured) {
      onChange([])
      return () => {}
    }
    const q = query(collection(db, 'projects', projectId, 'messages'), orderBy('createdAt','asc'))
    const unsub = onSnapshot(q, snap => onChange(snap.docs.map(d=> ({ id: d.id, ...d.data() }))))
    return unsub
  }

  const sendMessage = async (projectId, text) => {
    if (!isConfigured) {
      console.warn('sendMessage: Firebase not configured')
      return
    }
    try{
      await addDoc(collection(db, 'projects', projectId, 'messages'), { text, sender: user?.name || user?.email || 'me', createdAt: new Date() })
    }catch(e){ console.error(e) }
  }

  return (
    <FirebaseContext.Provider value={{ auth, db, user, signUp, signIn, createProject, listProjects, listMyProjectsWithOffers, streamProjectMessages, sendMessage }}>
      {children}
    </FirebaseContext.Provider>
  )
}

export const useFirebase = () => useContext(FirebaseContext)
export default app
