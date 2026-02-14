import Link from 'next/link'

export default function Home() {
  return (
    <div className="container">
      <header className="header">
        <h1>Mehad — Connect Clients & Contractors</h1>
        <nav>
          <Link href="/login">Login</Link> | <Link href="/signup">Sign up</Link>
        </nav>
      </header>

      <main>
        <p>Fast connections between clients and contractors. Minimal MVP.</p>
        <div className="cards">
          <Link href="/projects"><a className="card">Browse Projects</a></Link>
          <Link href="/create-project"><a className="card">Create Project</a></Link>
        </div>
      </main>

      <footer>© Mehad</footer>
    </div>
  )
}
