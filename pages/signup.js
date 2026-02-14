import { useState } from 'react'
import { useFirebase } from '../src/firebase'
import { useRouter } from 'next/router'

export default function Signup(){
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [role, setRole] = useState('Client')
  const { signUp } = useFirebase()
  const router = useRouter()

  const submit = async (e) => {
    e.preventDefault()
    const ok = await signUp({ name, email, password, role, description: '' })
    if (ok) router.push('/dashboard')
    else alert('Sign up failed')
  }

  return (
    <div className="container">
      <h2>Sign up</h2>
      <form onSubmit={submit} className="form">
        <input value={name} onChange={e=>setName(e.target.value)} placeholder="Name" />
        <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="Email" />
        <input type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="Password" />
        <select value={role} onChange={e=>setRole(e.target.value)}>
          <option>Client</option>
          <option>Contractor</option>
        </select>
        <button type="submit">Create account</button>
      </form>
    </div>
  )
}
