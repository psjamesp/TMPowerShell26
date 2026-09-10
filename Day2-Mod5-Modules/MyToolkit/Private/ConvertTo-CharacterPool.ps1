function ConvertTo-CharacterPool {
    # Private/internal helper function - intentionally NOT exported.
    # Demonstrates the public/private function pattern used in real modules.
    'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%'.ToCharArray()
}