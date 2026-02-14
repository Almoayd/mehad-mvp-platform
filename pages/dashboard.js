import Link from 'next/link'
import { useFirebase } from '../src/firebase'

export default function Dashboard(){
  const { user } = useFirebase()
  return (
    <div className="container">
      <header className="header">
        <h2>Dashboard</h2>
      </header>
      <main>
        <p>Welcome, {user?.name || user?.email || 'User'}</p>
        <div className="cards">
          <Link href="/create-project"><a className="card">Create Project</a></Link>
          <Link href="/projects"><a className="card">Projects Feed</a></Link>
          <Link href="/offers"><a className="card">Offers</a></Link>
          <Link href="/admin"><a className="card">Admin</a></Link>
        </div>
      </main>
    </div>
  )
}
