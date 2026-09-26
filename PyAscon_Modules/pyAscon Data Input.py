if __name__ == "__main__":

    # ---- HASH_256 DEBUG ----

    # messagein = "0102030405060708"
    messagein = "05319cf7ffec692672cf2722d8df7f27"
    # messagein = "78657420736968547373612073692074"
    # messagein = "277fdfd82227cf722669ecfff79c3105"

    message = bytearray.fromhex(messagein)
    tag = ascon_hash(message, "Ascon-Hash256", 32, "")

    demo_print([("message", message), ("customization", b""), ("tag", tag)])


    #-------------------------------------------------------------------
    # ---- AEAD128 DEBUG ----

    keyin            = "2e45359eff1340ab04b32a1d09bd7f3b"
    noncein          = "ea9432a05bf1e53c853086621be55680"
    plaintextin      = "05319cf7ffec692672cf2722d8df7f27"
    associateddatain = "54686973207465787420697320617373"

    # keyin            = "ab4013ff9e35452e3b7fbd091d2ab304"
    # noncein          = "3ce5f15ba03294ea8056e51b62863085"
    # plaintextin      = "78657420736968547373612073692074"
    # associateddatain = "54686973207465787420697320617373"

    # keyin            = "3b7fbd091d2ab304ab4013ff9e35452e"
    # noncein          = "8056e51b628630853ce5f15ba03294ea"
    # plaintextin      = "277fdfd82227cf722669ecfff79c3105"
    # associateddatain = "73736120736920747865742073696854"
  
    key = bytearray.fromhex(keyin)
    nonce = bytearray.fromhex(noncein)
    associateddata = bytearray.fromhex(associateddatain)
    plaintext      = bytearray.fromhex(plaintextin)

    variant = "Ascon-AEAD128" #"Ascon-128a"
    ciphertext        = ascon_encrypt(key, nonce, associateddata,
                                                            plaintext,  variant)
    receivedplaintext = ascon_decrypt(key, nonce, associateddata, ciphertext,
                                                                        variant)

    if receivedplaintext == None: print("verification failed!")
        
    demo_print([("key", key), 
                ("nonce", nonce), 
                ("plaintext", plaintext), 
                ("ass.data", associateddata), 
                ("ciphertext", ciphertext[:-16]), 
                ("tag", ciphertext[-16:]), 
                ("received", receivedplaintext), 
               ])
