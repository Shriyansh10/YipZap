'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { useAuth } from '@/hooks/use-auth'
import { LoginPromptModal } from '@/components/auth/login-prompt-modal'
import { PostMemeModal } from '@/components/memes/post-meme-modal'

export function FloatingActionButton() {
  const { user } = useAuth()
  const [showLoginModal, setShowLoginModal] = useState(false)
  const [showPostModal, setShowPostModal] = useState(false)

  const handleClick = () => {
    if (user) {
      setShowPostModal(true)
    } else {
      setShowLoginModal(true)
    }
  }

  return (
    <>
      <Button
        size="lg"
        className="fixed bottom-6 right-6 h-14 w-14 rounded-full shadow-lg hover:shadow-xl transition-all duration-200 z-30 bg-blue-600 hover:bg-blue-700"
        onClick={handleClick}
      >
        <Plus className="h-6 w-6" />
        <span className="sr-only">Post Meme</span>
      </Button>

      <LoginPromptModal
        open={showLoginModal}
        onOpenChange={setShowLoginModal}
      />

      <PostMemeModal
        open={showPostModal}
        onOpenChange={setShowPostModal}
      />
    </>
  )
}