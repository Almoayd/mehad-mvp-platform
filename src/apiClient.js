const api = {
  async signUp(data){
    const r = await fetch('/api/auth/signup',{ method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(data) })
    return r.json()
  },
  async signIn(data){
    const r = await fetch('/api/auth/login',{ method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(data) })
    return r.json()
  },
  async listProjects(){
    const r = await fetch('/api/projects')
    return r.json()
  },
  async createProject(data){
    const r = await fetch('/api/projects',{ method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(data) })
    return r.json()
  },
  async listMessages(projectId){
    const r = await fetch(`/api/projects/${projectId}/messages`)
    return r.json()
  },
  async sendMessage(projectId, text, sender){
    const r = await fetch(`/api/projects/${projectId}/messages`,{ method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({ text, sender }) })
    return r.json()
  }
}

export default api
