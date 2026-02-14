import { useState } from 'react'
import { useFirebase } from '../src/firebase'
import { useRouter } from 'next/router'

export default function Login(){
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const { auth, signIn } = useFirebase()
  const router = useRouter()

  const submit = async (e) => {
    e.preventDefault()
    const ok = await signIn(email, password)
    if(ok) router.push('/dashboard')
    else alert('Sign in failed')
  }

  return (
    <div className="container">
      <h2>Login</h2>
      <form onSubmit={submit} className="form">
        <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="Email" />
        <input type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="Password" />
        <button type="submit">Sign in</button>
      </form>
    </div>
  )
}
